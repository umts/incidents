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
end
