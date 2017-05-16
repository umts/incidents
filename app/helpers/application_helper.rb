module ApplicationHelper
  def yes_no(value)
    value ? 'Yes' : 'No'
  end

  def yes_no_image(value)
    if value
      content_tag :span, nil, class: 'glyphicon glyphicon-ok'
    else content_tag :span, nil, class: 'glyphicon glyphicon-remove'
    end
  end
end
