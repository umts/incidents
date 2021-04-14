# frozen_string_literal: true

module HumanizationHelper
  def human_name(model, name)
    text = t name, scope: [:activerecord, :attributes, model]
    text.index(/[?.]/) ? text : "#{text}:"
  end
end
