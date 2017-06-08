# frozen_string_literal: true

module ApplicationHelper

  def a11y_datetime_labels(tag_id)
    %w[Year Month Day Hour Minute].map.with_index do |name, i|
      content_tag :label, nil, class: 'a11y-read', for: tag_id + "_#{i + 1}i" do
        name
      end
    end
  end

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
