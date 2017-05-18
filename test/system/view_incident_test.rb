# frozen_string_literal: true

require 'application_system_test_case'

class ViewIncidentTest < ApplicationSystemTestCase
  test 'drivers can view their own incidents' do
    incident = create :incident
    when_current_user_is incident.driver
    visit incident_url(incident)

    assert_text incident.description
  end

  test 'drivers cannot view incidents of others' do
    when_current_user_is :driver
    visit incident_url(create :incident)

    assert_text 'You do not have permission to access this page.'
  end
end
