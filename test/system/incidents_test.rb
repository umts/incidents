require 'application_system_test_case'

class IncidentsTest < ApplicationSystemTestCase
  test 'visiting the index as staff shows incidents in the current month' do
    when_current_user_is :staff

    Timecop.freeze Date.new(2017, 5, 15) do
      incident_for 'Shera Hessel', occurred_at: 1.month.ago
      incident_for 'Trudie Borer', occurred_at: Date.today
      incident_for 'Nona Strosin', occurred_at: 1.month.since

      visit incidents_url
    end

    assert_selector 'h1', text: 'Incidents'
    assert_selector 'h2', text: 'Monday, May 1 — Wednesday, May 31'
    assert_selector 'a.switch button', text: 'View single week'
    assert_selector 'table.incidents tr td', text: 'Trudie Borer'

    assert_no_selector 'table.incidents td', text: 'Shera Hessel'
    assert_no_selector 'table.incidents td', text: 'Nona Strosin'
  end

  test "visiting the index as a driver shows all of the driver's incidents" do
    driver = create :user, :driver, name: 'Alfred Bergnaum'
    when_current_user_is driver

    incident_for driver
    incident_for 'Evelyn Parisian'
    incident_for 'Eusebia Farrell'

    visit incidents_url

    assert_selector 'h1', text: 'Your Incidents'
    assert_selector 'table.incidents td', text: 'Alfred Bergnaum'

    assert_no_selector 'table.incidents td', text: 'Evelyn Parisian'
    assert_no_selector 'table.incidents td', text: 'Eusebia Farrell'
  end
end
