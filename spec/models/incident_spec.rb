require 'spec_helper'

describe Incident do
  describe 'notify_supervisor_of_new_report' do
    let(:incident) { create :incident }
    context 'with a supervisor email' do
      it 'sends an email' do
        incident.supervisor.update email: 'supervisor@example.com'
        expect { incident.notify_supervisor_of_new_report }
          .to change { ActionMailer::Base.deliveries.count }
      end
    end
    context 'with no supervisor email' do
      it 'does not send an email' do
        expect(incident.supervisor.email).not_to be_present
        expect { incident.notify_supervisor_of_new_report }
          .not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end

  describe 'validations' do
    context 'supervisor report not belonging to a supervisor' do
      it 'fails' do
        driver = create :user, :driver
        report = create :incident_report, user: driver
        incident = build :incident, supervisor_incident_report: report
        expect(incident).not_to be_valid
      end
    end
  end

  describe 'automated emails' do
    context 'when staff have emails' do
      let!(:staff) { create :user, :staff, email: 'staff@example.com' }
      it 'sends those staff email about new incidents' do
        expect { create :incident }
          .to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end