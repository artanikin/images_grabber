class ImgGrabController < ApplicationController

  

  def index
  end

  def grabber

    scheme = "http://"
    uri = "rezh-internat.ru"
    uri = uri.prepend_if_not_exist(scheme)
    
    @images = get_urls_images(uri)
    
    dir = get_name_dir(uri)
    FileUtils.makedirs(dir)

    threads = @images.map do |img_uri|
      Thread.new { download_image(img_uri, dir) }
    end

    threads.each &:join

    @size = threads.size

  end

  private 

    def get_urls_images(uri)
      images = []
      open(uri) do |f|
        page = Nokogiri::HTML(f.read)
        base_uri = f.base_uri
        page.css('img').each do |img|
          src = img[:src]
          images << make_correct_link(src, base_uri) if is_image?(src)
        end
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

    def get_name_dir(uri)
      uri = uri.gsub(/^(http:\/\/|https:\/\/)/, "").split("\/").join('_')
      uri.prepend "./app/assets/images/downloaded/"
    end

    def download_image(image_src, dir)
      img = open(image_src, 'rb').read
      name = image_src.match(/[\w\.-]+$/i)
      File.open("#{dir}/#{name}", 'wb') { |file| file.write img }
    end

end
