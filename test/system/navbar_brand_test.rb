# frozen_string_literal: true

require 'application_system_test_case'

class NavbarBrandTest < ApplicationSystemTestCase
  test 'the navbar brand logo goes to the root path' do
    when_current_user_is :driver
    visit root_url
    assert_selector '.navbar a.navbar-brand'
    assert find('.navbar a.navbar-brand')['href'].include? root_url[0..-2]
  end
end
