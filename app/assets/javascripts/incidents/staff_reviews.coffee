$(document).ready ->
  $('.staff-review').on 'click', 'button.edit', () ->
    $(this).siblings('p').hide()
    $(this).siblings('a.delete').hide()
    $(this).hide()
    $(this).siblings('form.edit-review').show()
