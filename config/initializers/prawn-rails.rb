require 'prawn-rails'

PrawnRails.config do |config|
  config.page_layout = :portrait
  config.page_size = 'LETTER'
  config.skip_page_creation = true
end
