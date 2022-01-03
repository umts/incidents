# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'db:amplifying_comments' do
  reason = 'A very good reason'
  comment = 'wow a comment'

  before :all do
    @sr1 = create :supervisor_report, test_status: 'Post Accident: Threshold met and discounted (no drug test)',
                                      reason_driver_discounted: reason, amplifying_comments: comment
    @sr2 = create :supervisor_report, test_status: 'Reasonable Suspicion: Completed drug test',
                                      reason_threshold_not_met: comment, amplifying_comments: comment
    @sr3 = create :supervisor_report, test_status: 'Post Accident: No threshold met (no drug test)',
                                      reason_threshold_not_met: reason, amplifying_comments: comment
    @sr4 = create :supervisor_report, test_status: 'Reasonable Suspicion: Completed drug test',
                                      reason_threshold_not_met: reason, amplifying_comments: comment
    Rake.application.rake_require 'tasks/amplifying_comments'
    Rake::Task.define_task(:environment)
    Rake.application.invoke_task 'db:amplifying_comments'
  end

  context 'when test status is driver discounted' do
    it 'has reason_driver_discounted prepend amplifying_comments' do
      expect(@sr1.reload.amplifying_comments).to eq "#{reason}\n\n#{comment}"
    end

    it 'does not change the amplifying_comments' do
      expect(@sr2.reload.amplifying_comments).to eq comment
    end
  end

  context 'when test status is threshold not met' do
    it 'has reason_threshold_not_met prepend amplifying_comments' do
      expect(@sr3.reload.amplifying_comments).to eq "#{reason}\n\n#{comment}"
    end
  end

  context 'when test status is something else' do
    it 'does not change the amplifying_comments' do
      expect(@sr4.reload.amplifying_comments).to eq comment
    end
  end
end
