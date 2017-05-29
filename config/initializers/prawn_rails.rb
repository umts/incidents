require 'prawn-rails'

include PrawnFormBoxes

PrawnRails.config do |config|
  config.page_layout = :portrait
  config.page_size = 'LETTER'
  config.skip_page_creation = true
  # The given form has pretty small margins.
  config.margin = 26 # pt.
end
