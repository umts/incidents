# frozen_string_literal: true

require 'spec_helper'

describe 'printing incidents' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  it 'shows a place to print incidents', js: true do
    report = create :incident_report, :with_incident, user: driver
    visit incidents_url

    expect(page)
      .to have_link('Print', href: incident_path(report.incident, format: :pdf))
  end
end
