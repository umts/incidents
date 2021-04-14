# frozen_string_literal: true

require 'uri'

module ApplicationHelper
  def a11y_date_labels(tag_id)
    a11y_rails_native_select_labels(tag_id, %w[Year Month Day])
  end

  def a11y_datetime_labels(tag_id)
    a11y_rails_native_select_labels(tag_id, %w[Year Month Day Hour Minute])
  end

  def maps_source
    URI::HTTPS.build host: 'maps.googleapis.com',
                     path: '/maps/api/js',
                     query: {
                       key: Rails.application.secrets.google_maps_api_key
                     }.to_query
  end

  def yes_no(value)
    value ? 'Yes' : 'No'
  end

  def yes_no_image(value)
    content_tag :span, nil, class: "glyphicon glyphicon-#{value ? 'ok' : 'remove'}"
  end

  private

  def a11y_rails_native_select_labels(tag_id, fields)
    fields.map.with_index 1 do |name, index|
      content_tag :label, nil, class: 'a11y-read', for: tag_id + "_#{index}i" do
        name
      end
    end
  end
end
