# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupervisorReport do
  context 'when a supervisor report has a test status' do
    it 'fails to save with no amplifying comments' do
      sr = build_stubbed :supervisor_report, :with_test_status, amplifying_comments: ''
      expect(sr).not_to be_valid
    end

    it 'fails to save when the test_status is not in REASONS_FOR_TEST' do
      sr = build_stubbed :supervisor_report, test_status: 'some test status', amplifying_comments: 'comments'
      expect(sr).not_to be_valid
    end

    it 'saves when the test_status is blank' do
      sr = build_stubbed :supervisor_report, test_status: '', amplifying_comments: 'comments'
      expect(sr).to be_valid
    end
  end

  describe 'fta_justifications' do
    it 'returns the correct string' do
      sr = build_stubbed :supervisor_report, :with_test_status, amplifying_comments: 'some comments'
      test_reason_pretext = SupervisorReport::REASONS_FOR_TEST[sr.test_status]
      expect(sr.fta_justifications).to eq "#{test_reason_pretext}some comments"
    end
  end
end
