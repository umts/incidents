module IncidentsHelper
  def yes_no_image(value)
    if value
      content_tag :span, nil, class: 'glyphicon glyphicon-ok'
    else content_tag :span, nil, class: 'glyphicon glyphicon-remove'
    end
  end
end
