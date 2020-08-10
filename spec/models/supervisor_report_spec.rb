require 'spec_helper'

describe SupervisorReport do
  describe 'completed_drug_or_alcohol_test?' do
    it 'returns test not conducted' do
      supervisor_report = create :supervisor_report, test_not_conducted: true
      expect(supervisor_report.completed_drug_or_alcohol_test?).to eq false
    end
  end
end
