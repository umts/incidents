require 'application_system_test_case'

class IncidentsTest < ApplicationSystemTestCase
  test 'visiting the index as staff' do
    when_current_user_is :staff
    visit incidents_url
    assert_selector 'h1', text: 'Incidents'
  end
end
