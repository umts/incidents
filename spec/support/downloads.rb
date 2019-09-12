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

  def last_download
    wait_for_download
    downloads.sort_by(&:mtime).last
  end

  private

  def wait_for_download
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.1
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    Time.now - PATH.mtime < 0.2
  end
end
