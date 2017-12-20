module HumanizationHelper
  def human_name(model, name)
    text = t name, scope: [:activerecord, :attributes, model]
    if text.end_with? '?'
      text
    else text + ':'
    end
  end
end
