# encoding: UTF-8

require 'test_helper'

class EnvironmentTest < ActionController::IntegrationTest

  
  test "environment loader" do
    assert ENV['LOADED']=='test',"test.env did not load"
  end
  
end