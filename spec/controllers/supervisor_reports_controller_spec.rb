require 'spec_helper'

describe SupervisorReportsController do
  describe 'POST #update' do
    context 'with an invalid report' do
      let!(:supervisor_report) { create :supervisor_report }
      it 'renders the edit page' do
        when_current_user_is :supervisor
        expect_any_instance_of(SupervisorReport)
          .to receive(:update).and_return false
        post :update, params: { id: supervisor_report.id, supervisor_report: { pictures_saved: true } }
        expect(response).to render_template 'edit'
      end
    end
  end
end
