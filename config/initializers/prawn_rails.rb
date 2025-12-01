require 'prawn-rails/document'
require 'prawn-rails-forms'

#TODO: Fixed by umts/prawn-rails-forms#23
PrawnRailsForms.send(:extend, PrawnRailsForms)

PrawnRails.config do |config|
  config.page_layout = :portrait
  config.page_size = 'LETTER'
  config.skip_page_creation = true
  # The given form has pretty small margins.
  config.margin = 26 # pt.
end
