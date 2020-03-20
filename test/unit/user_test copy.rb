require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @network = Network.create
    @station = @network.stations.create(:host=>"newstation",:name=>"station",:title=>"New Station")
  end

  test "user index inheritance" do
    #test our index fields are working properly
    assert !Thing._index_variables.has_key?(1), "should not have location variable"
    assert User._index_variables.has_key?(1), "should have location variable"
  end
  
  test "user create" do
    u = @station.users.build(:name=>"user",:title=>"User Profile",:content=>"This is a user profile.")    

    assert !u.valid?, "should require email and password"
    u = @station.users.build(:email=>"test@user.com",:password=>"password",:accept_terms=>true,:name=>"user",:title=>"User Profile",:content=>"This is a user profile.")    

    assert u.valid?, u.errors.to_s 
    
  end

end