$(document).ready ->
  $('.staff-review').on 'click', 'button.edit', () ->
    $(this).siblings('.text').hide()
    $(this).siblings('a.delete').hide()
    $(this).hide()
    $(this).siblings('form.edit-review').show()
    $('form.edit-review textarea').trigger('focus')
