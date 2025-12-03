require 'prawn_rails_forms'

PrawnRails.config do |config|
  config.page_layout = :portrait
  config.page_size = 'LETTER'
  config.skip_page_creation = true
  # The given form has pretty small margins.
  config.margin = 26 # pt.
end

ActiveSupport.on_load(:action_view) do
  PrawnRails::Document.include PrawnRailsForms::DocumentExtensions
end
