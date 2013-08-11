# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Подключение модуля fancybox, для отображения изображений в увеличенном виде.
jQuery ->
  $('a.grouped_elements').fancybox()