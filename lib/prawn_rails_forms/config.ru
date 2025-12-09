# frozen_string_literal: true

require 'action_controller/railtie'
require 'action_view/railtie'

$LOAD_PATH.unshift File.expand_path('..', __dir__)

class TestApp < Rails::Application
  require 'prawn-rails'
  require 'prawn_rails_forms'

  config.load_defaults 6.1
  config.eager_load = false
  config.consider_all_requests_local = true

  PrawnRails.config do |c|
    c.page_layout = :landscape
    c.margin = 30
  end

  ActiveSupport.on_load(:action_view) do
    PrawnRails::Document.include PrawnRailsForms::DocumentExtensions
  end

  routes.append do
    root 'pdf#static', defaults: { format: 'pdf' }
  end
end

# rubocop:disable Rails/ApplicationController
class PdfController < ActionController::Base
  append_view_path __dir__

  def static
    render pdf: 'static'
  end
end
# rubocop:enable Rails/ApplicationController

Rails.application.initialize!
run Rails.application
Rails.application.load_server
