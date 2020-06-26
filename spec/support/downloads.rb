# frozen_string_literal: true

module Downloads
  extend self

  PATH = Rails.root.join('spec', 'downloads')

  def downloads
    PATH.glob('*')
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end

  def wait_for(filename)
    Timeout.timeout Capybara.default_max_wait_time do
      loop do
        break if PATH.join(filename).exist?
      end
    end
  end
end
