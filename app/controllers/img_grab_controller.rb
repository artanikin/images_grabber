class ImgGrabController < ApplicationController

  BASE_DIR = "./app/assets/images/downloaded/"

  def index
  end

  def booties
    @dirs = []
    Dir.foreach(BASE_DIR) do |dir|
      unless dir.eql?(".") or dir.eql?("..")
        @dirs << get_dir_info(dir)
      end
    end
  end

  def show_booty
    @dir = params[:dir] if params[:dir]
    path = "#{BASE_DIR}#{@dir}"

    if File.directory? path
      @images = Dir.entries path
      @images.delete_if { |x| x == "." or x ==".." }
    else
      flash[:danger] = "This directory does not exist."
      redirect_to booties_path
    end
  end

  def grabber
    begin

      scheme, input_uri = params[:scheme], params[:uri]
      input_uri = input_uri.prepend("#{scheme}://") unless input_uri.start_with?("http://", "https://")
      uri = URI(input_uri)

      agent  = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      page   = agent.get(uri)
      images = page.images

      unless images.empty?
        uniq_src_img = []
        images.each { |image| uniq_src_img << image.to_s if is_image? image.to_s }
        uniq_src_img.uniq!

        dir = make_dir(uri.to_s)

        report  = download(uniq_src_img, dir)
        runtime = Time.at(report[:runtime]).strftime("%M:%S")

        flash[:success] = "Congratulations! Uploaded #{report[:uploaded]} pictures. Runtime #{runtime} sec."
        redirect_to booties_path
      else
        set_notice("warning", "We're sorry. But on the page is not found pictures.", "warning")
      end

    rescue URI::InvalidURIError
      set_notice("danger", "Sorry, your entered URL not correctly.")
    rescue Mechanize::ResponseCodeError => error
      set_notice("danger", "Sorry, got a bad page status code #{error.response_code}.")
    rescue Errno::ENOENT
      set_notice("danger", "Sorry, you typed not existing page address.")
    rescue
      set_notice("danger", "Sorry, an unexpected error has occurred.")
    end
  end

  private 

    def set_notice(type, message, class_field="error" )
      flash.now[type] = message
      @add_class = class_field
      @uri = params[:uri]
      render :index
    end

    def is_image?(uri)
      pattern = /[[:graph:]]+(\.png|\.jpg|\.jpeg|\.gif|\.bmp|\.ico|\.svg)/i
      uri.match(pattern)
    end

    def make_dir(uri)
      dir = get_name_dir(uri)
      FileUtils.remove_dir(dir) if File.directory? dir
      FileUtils.makedirs(dir)
      dir
    end

    def get_name_dir(uri)
      uri = uri.gsub(/^(http:\/\/|https:\/\/)|(\?)/, "").split("\/").join('_')
      uri.prepend BASE_DIR
    end
  
    def download(urls, dir)
      start_time = Time.now
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      mutex = Mutex.new
      thread = []
      report = { uploaded: 0, not_uploaded: 0, runtime: 0 }

      urls.each do |url|
        thread << Thread.new do
          begin
            file = nil
            mutex.synchronize do 
              file = agent.get(url)
            end
            if file
              file_name = file.filename
              file.save "#{dir}/#{file_name}"
              mutex.synchronize { report[:uploaded] += 1 }
              # Thread.current.exit
            end
          rescue 
            mutex.synchronize { report[:not_uploaded] += 0 }
          end
        end
      end

      thread.each { |t| t.join }

      report[:runtime] = (Time.now - start_time).to_f
      report
    end

    def get_dir_info(dir)
      dir_info = {}
      path = "#{BASE_DIR}#{dir}"

      files = Dir.entries(path) 
      files.delete_if { |x| x == "." or x == ".." }

      dir_info[:name]  = dir
      dir_info[:count] = files.count

      dir_info
    end
end
