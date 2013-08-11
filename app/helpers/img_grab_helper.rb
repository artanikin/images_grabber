module ImgGrabHelper

  # Создаётся блок контента, который содержит картинку и
  # подпись к ней (имя картинки в файловой системе).
  def create_content_block(dir, image)
    content = []
    content << image_tag("/assets/downloaded/#{@dir}/#{image}")
    content << content_tag(:span, image)

    content.join.html_safe
  end
end
