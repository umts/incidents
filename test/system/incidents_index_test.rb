require 'application_system_test_case'

class IncidentsIndexTest < ApplicationSystemTestCase

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
    assert_incident_for 'Trudie Borer'

    assert_no_incident_for 'Shera Hessel'
    assert_no_incident_for 'Nona Strosin'
  end

  test 'moving to the previous month shows incidents in that month' do
    when_current_user_is :staff

    Timecop.freeze Date.new(2017, 5, 15) do
      incident_for 'Nanci Kuvalis', occurred_at: 1.month.ago
      incident_for 'Kathie Ledner', occurred_at: Date.today

      visit incidents_url
    end

    assert_selector 'table.incidents td', text: 'Kathie Ledner'

    click_button 'Previous month'

    assert_selector 'h2', text: 'Saturday, April 1 — Sunday, April 30'
    assert_incident_for 'Nanci Kuvalis'
  end

  test 'switching from month to week goes to the first week in the month' do
    when_current_user_is :staff

    Timecop.freeze Date.new(2017, 5, 15) do
      incident_for 'Malorie Gulgowski', occurred_at: 2.weeks.ago
      incident_for 'Marcelina Okuneva', occurred_at: Date.today

      visit incidents_url
    end

    click_button 'View single week'

    assert_selector 'h2', text: 'Sunday, April 30 — Saturday, May 6'

    assert_incident_for 'Malorie Gulgowski'
    assert_no_incident_for 'Marclinea Okuneva'
  end

  test 'switching from mid-month week to month works as expected' do
    when_current_user_is :staff

    visit incidents_url(mode: 'week', start_date: '2017-05-07')

    assert_selector 'h2', text: 'Sunday, May 7 — Saturday, May 13'

    click_button 'View for whole month'

    assert_selector 'h2', text: 'Monday, May 1 — Wednesday, May 31'
  end

  test 'one can specify an end date if one wishes' do
    when_current_user_is :staff

    visit incidents_url(start_date: '2017-05-01', end_date: '2017-06-30')

    assert_selector 'h2', text: 'Monday, May 1 — Friday, June 30'
  end

  test "visiting the index as a driver shows all of the driver's incidents" do
    driver = create :user, :driver, name: 'Alfred Bergnaum'
    when_current_user_is driver

    incident_for driver
    incident_for 'Evelyn Parisian'
    incident_for 'Eusebia Farrell'

    visit incidents_url

    assert_selector 'h1', text: 'Your Incidents'
    assert_incident_for 'Alfred Bergnaum'

    assert_no_incident_for 'Evelyn Parisian'
    assert_no_incident_for 'Eusebia Farrell'
  end
end
