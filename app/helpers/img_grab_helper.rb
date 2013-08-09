module ImgGrabHelper
  def create_link(dir, image)
    content = []

    content << image_tag("/assets/downloaded/#{@dir}/#{image}")
    content << content_tag(:span, image)

    content.join.html_safe
  end
end
