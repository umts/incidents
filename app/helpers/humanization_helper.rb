module HumanizationHelper
  def human_name(model, name)
    text = t name, scope: [:activerecord, :attributes, model]
    if text.include?('?') || text.include?('.')
      text
    else text + ':'
    end
  end
end
