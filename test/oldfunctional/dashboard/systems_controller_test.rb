require 'test_helper'

class Dashboard::SystemsControllerTest < ActionController::TestCase
  test "install" do

    get :install
    assert_redirected_to dashboard_system_path
    assert Station.count == 1
    assert Station.first.accounts.count == 1
    assert Station.first.users.count == 1

    get :install
    assert_redirected_to dashboard_system_path
    assert Station.count == 1, "Should not create duplicate root stations"
  end
end
