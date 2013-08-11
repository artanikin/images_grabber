# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  # Подключение модуля fancybox, для отображения изображений в увеличенном виде.
  $('a.grouped_elements').fancybox()

  # Добавление анимации к сообщениям
  $(".alert").hide().fadeIn(500)
  $(".alert-success").delay(5000).fadeOut(1500)

  # Устанавливаем фокус на поле ввода
  $("#uri").focus()
  # Показать блок загрузки при отправке формы серверу
  $("form").submit( -> $("#overlay_block").show())
  
