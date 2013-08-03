class ImgGrabController < ApplicationController
  def index
  end

  def grabber
    @url = get_url(params[:url])
  end

  private 

    def get_url(url)
      # TODO: 1. Проверить ввел ли пользователь имя протокола
      # => Если не ввел, то добавить
      # TODO: 2. Проверить ввел ли пользователь 'www'.
      # => Если нет, то добавить
      # TODO: 3. Вернуть правильную ссылку.
    end

end
