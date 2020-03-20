require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "invalid without params" do
    u = User.new
    assert !u.valid?, u.errors.full_messages.to_s 
  end
  
  test "valid user" do
    s =  Factory.create(:station)
    a = s.accounts.create
    u = Factory.create(:user,:account=>a,:station=>s)  
    assert u.valid?
  end

  test "don't allow duplicate users in station" do
    s =  Factory.create(:station)
    a = s.accounts.create
      
    u = Factory.create(:user,:account=>a,:station=>s,:screen_name=>"test",:email=>"user@test.com")  
    assert u.valid?

    u = Factory.build(:user,:account=>a,:station=>s,:screen_name=>"test",:email=>"user2@test.com")  
    assert !u.valid?, "screen name duplicate"

    u = Factory.build(:user,:account=>a,:station=>s,:screen_name=>"test2",:email=>"user@test.com")  
    assert !u.valid?, "email duplicate"

    s2 =  Factory.create(:station)
    a2 = s2.accounts.create
      
    u2 = Factory.create(:user,:account=>a2,:station=>s2,:screen_name=>"test",:email=>"user@test.com")  
    assert u2.valid?, "duplicate in different station"
      
  end

end
