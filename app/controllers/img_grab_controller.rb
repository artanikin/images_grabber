class ImgGrabController < ApplicationController

  BASE_DIR = "./app/assets/images/"

  def index
  end


  def booties
    # Отображает все директории, в которых сохранены картинки.
    begin
      @dirs = []
      Dir.foreach(BASE_DIR) do |dir|

        if File.directory?("#{BASE_DIR}#{dir}")
          # Получение дополнительной информации о директории
          @dirs << get_dir_info(dir) unless dir.eql?(".") or dir.eql?("..")
        end
      end
      
      # Если папка пуста, то отображается сообщение об ошибке
      raise Errno::ENOENT if @dirs.empty?

    rescue Errno::ENOENT
      # Если папка пуста, то отображается сообщение об ошибке
      set_notice_with_redirect("danger", "This section is empty.")
    end
  end


  def show_booty
    # Отображает картинки в переданной директории
    if params[:dir]
      @dir = params[:dir] 
      path = "#{BASE_DIR}#{@dir}"

      if File.directory? path
        # Если директория существует, то отображается её содержимое.
        @images = Dir.entries path
        @images.delete_if { |x| x == "." or x ==".." }
        
        set_notice_with_redirect("danger", "There is no image for the page. Try to load them again.", booties_path) if @images.empty?
      else
        # Если нет, то пользователь перенаправляется на action booties и
        # выводится предупреждение.
        set_notice_with_redirect("danger", "This directory does not exist.", booties_path)
      end
    else
      set_notice_with_redirect("danger", "This directory does not exist.", booties_path)
    end
  end


  def grabber
    # Получает введенный адрес страницы и скачивает все изображения.
    begin
      scheme, input_uri = params[:scheme], params[:uri]
      input_uri = input_uri.prepend("#{scheme}://") unless input_uri.start_with?("http://", "https://")
      uri = URI(input_uri)

      # Получает код страницы и передает в массив images все картинки.
      agent  = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      page   = agent.get(uri)
      images = page.images

      unless images.empty?
        # Если на странице имеются изображения, то получаем массив
        # с их уникальными (не дублирующимися) адресами.
        uniq_src_img = []
        images.each { |image| uniq_src_img << image.to_s if is_image? image.to_s }
        uniq_src_img.uniq!

        # Создается директория для сохранения в нее изображений.
        dir = make_dir(uri.to_s)

        # Загрузка изображений и получение отчета о загрузке.
        report  = download(uniq_src_img, dir)
        runtime = Time.at(report[:runtime]).strftime("%M:%S")

        # Вывод сообщения о успешной закгрузке и перенеправление
        # на страницу с загруженными изображениями
        set_notice_with_redirect("success", "Congratulations! Uploaded #{report[:uploaded]} pictures. Runtime upload #{runtime} sec.", booties_path)
      else
        set_notice("warning", "We're sorry. But on the page is not found pictures.", "warning")
      end

    # Отлавливает возможные ошибки в приложении и выводит сообщение.
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
      # Устанавливает переданное сообщение во flash.
      # Добавляет переданный класс к полю ввода.
      # Отображает главную страницу.
      flash.now[type] = message
      @add_class = class_field
      @uri = params[:uri]
      render :index
    end

    def set_notice_with_redirect(type, message, path=root_path)
      # Перенапрвляет на страницу с закачанными катинками и
      # выводит сообщение.
      flash[type] = message
      redirect_to path
    end


    def is_image?(uri)
      # Проверка, является ли переданное значение, именем изображения
      pattern = /[[:graph:]]+(\.png|\.jpg|\.jpeg|\.gif|\.bmp|\.ico|\.svg)/i
      uri.match(pattern)
    end


    def make_dir(uri)
      # Если переданная директория уже существует,
      # то она удаляется и на её месте создается новая.
      # Если не существует, то создаётся.
      dir = get_name_dir(uri)
      FileUtils.remove_dir(dir) if File.directory? dir
      FileUtils.makedirs(dir)
      dir
    end

    def get_name_dir(uri)
      # Получение полного пути, для переданной директории
      uri = uri.gsub(/^(http:\/\/|https:\/\/)|(\?)/, "").split("\/").join('_')
      uri.prepend BASE_DIR
    end
  

    def download(urls, dir)
      # Паралельная загрузка изображений и вывод отчета о загрузке.
      start_time = Time.now
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      mutex = Mutex.new
      thread = []
      report = { uploaded: 0, not_uploaded: 0, runtime: 0 }

      urls.each do |url|
        # Для каждого адреса изображения, создатся новый поток.
        thread << Thread.new do
          begin
            file = nil
            mutex.synchronize do 
              # Не позволяет использовать объект agent несколькими 
              # потоками одновременно.
              file = agent.get(url)
            end

            if file
              # Если изображение получено, то оно сохраняется.
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

      # Главный поток дожидается выполнения дочерних.
      thread.each { |t| t.join }

      # Вывод отчета о загруженных изображениях.
      report[:runtime] = (Time.now - start_time).to_f
      report
    end


    def get_dir_info(dir)
      # Метод возвращает хэш, содержащий имя директории и
      # количество картинок в ней.
      dir_info = {}
      path = "#{BASE_DIR}#{dir}"

      # Получает содержимое директории и удаляет из нее
      # корневые директории "."" и ".."
      files = Dir.entries(path) 
      files.delete_if { |x| x == "." or x == ".." }

      dir_info[:name]  = dir
      dir_info[:count] = files.count

      dir_info
    end
end
