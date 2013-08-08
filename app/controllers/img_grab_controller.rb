class ImgGrabController < ApplicationController

  def index
  end

  def bootys

    @dirs = []
    Dir.foreach("./app/assets/images/downloaded/") do |dir|
      @dirs << dir unless dir.index /^\.{1}+$/
    end
    @dirs.sort!

  end

  def show_booty
  end

  def grabber
    scheme, uri = params[:scheme], params[:uri]
    uri = uri.prepend_if_not_exist("#{scheme}://")
 
    begin
      open(uri) do |page|
        @images = get_urls_images(page)
        dir = make_dir(uri)
        download_images(@images, dir)
        img_count = @images.count
        flash[:success] = "Congratulations! Downloaded all the images."
        redirect_to root_path
      end
    rescue
      flash.now[:danger] = "The URL you entered does not work"
      @add_class = "error"
      @uri = params[:uri]
      render :index
    end
  end

  private 

    def get_urls_images(page)
      images = []
      base_uri = page.base_uri
      html_page = Nokogiri::HTML(page)
      html_page.css('img').each do |img|
        src = img[:src]
        images << make_correct_link(src, base_uri) if is_image?(src)
      end
      images.uniq
    end

    def is_image?(uri)
      pattern = /[[:graph:]]+(\.png|\.jpg|\.jpeg|\.gif|\.bmp|\.ico|\.svg)/i
      uri.match(pattern)
    end

    def make_correct_link(img_src, uri)
      if img_src.match(/^\/{1}[\w\d\.\-_]+/i) then
        img_src = img_src.prepend_if_not_exist(uri.host)
      elsif img_src.match(/^\/{2}[\w\d\.\-_]+/i) then
        img_src = img_src.gsub(/^(\/{2})/, "")
      end
      img_src.prepend_if_not_exist("#{uri.scheme}://")
    end
    

    def make_dir(uri)
      dir = get_name_dir(uri)
      FileUtils.remove_dir(dir) if File.directory? dir
      FileUtils.makedirs(dir)
      dir
    end

    def get_name_dir(uri)
      uri = uri.gsub(/^(http:\/\/|https:\/\/)/, "").split("\/").join('_')
      uri.prepend "./app/assets/images/downloaded/"
    end


    def download_images(images_src, dir)
      queue = SizedQueue.new(20)
      @mutex = Mutex.new
      thread = []

      images_src.each do |src|
        Thread.new do
          img = open(src, 'rb') { |img_src| img_src.read }
          name = src.match(/[\w\.-]+$/i)
          queue.push(img: img, name: name)
        end
      end

      images_src.count.times do
        thread << Thread.new do
          img = nil
          @mutex.synchronize { img = queue.pop }

          if img
            path = "#{dir}/#{img[:name]}"
            File.open(path, 'wb') { |file| file.write img[:img] }
          end
        end
      end
      thread.each { |t| t.join; }
    end

end
