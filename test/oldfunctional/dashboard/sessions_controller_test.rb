require 'test_helper'

class Dashboard::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    setup_controller_for_warden
    @request.env["devise.mapping"] = Devise.mappings[:user]  
    Factory.create :station_with_content  
  end
  
  test "sign in page" do
    get :new #new_user_session_path
    #assert :success
    assert_response :success
    assert_template "dashboard/sessions/new"
  end
  
  test "sign in error" do
    sign_out :user
    post :create, :user=>{:email=>"admin@user.com",:password=>"wrongpassword",:remember_me=>false}
    #assert_equal 200, @response.status
    assert_response :success, "response should still be success"
    assert_template "dashboard/sessions/new"
  end

  test "sign in valid" do
    sign_out :user
    post :create, :user=>{:email=>"admin@user.com",:password=>"password",:remember_me=>false}
    assert_redirected_to root_path

  end

end
