# frozen_string_literal: true

RSpec::Matchers.define :download_file_named do |expected|
  match do |actual|
    actual.call

    @requested_file = expected.to_s.split('/').last
    @last_download_name = Downloads.last_download.basename.to_s
    @last_download_name == @requested_file
  end

  failure_message do
    "expected that #{@requested_file} would be downloaded, " \
    "but #{@last_download_name} was most recently downloaded"
  end

  supports_block_expectations
end
