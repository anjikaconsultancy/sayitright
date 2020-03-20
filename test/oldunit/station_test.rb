require 'test_helper'

class StationTest < ActiveSupport::TestCase
  test "create root" do
    s =  Factory.create(:station)
    assert s.valid?
    assert Station.count == 1
  end

  test "create station with content" do
    s =  Factory.create(:station_with_content)
    assert s.valid?
    assert s.domains.count == 1 , "domains" + s.domains.count.to_s
    assert s.accounts.count == 1 , "accounts" + s.accounts.count.to_s
    assert s.users.count == 1 , "users" + s.users.count.to_s

  end
    
  test "active states without owner" do
    #root station does not need an account, check active states still work
    s = Factory.create(:station)
    
    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})
    assert s.active?
    assert s.listed?, "listed and active"

    s.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})
    assert !s.active?
    assert !s.listed?, "disabled so unlisted"

    s.update_attributes({:enabled=>true,:disabled=>true,:locked=>true})
    assert !s.active?
    assert !s.listed?, "locked so unlisted"

    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>false,:visible=>false})
    assert s.active?, "hidden but still enabled"
    assert !s.listed?, "unlisted but still enabled"

  end

  test "active scope without owner" do
    s = Factory.create(:station)
    
    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})
    assert Station.active.count == 1
    assert Station.listed.count == 1

    s.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})
    assert Station.active.count == 0
    assert Station.listed.count == 0
    
    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>true})
    assert Station.active.count == 0
    assert Station.listed.count == 0
    
    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>false,:visible=>false})
    assert Station.active.count == 1, "hidden but still enabled"
    assert Station.listed.count == 0, "unlisted but still enabled"    
    
  end
  
  test "active states with owner" do
    r = Factory.create(:station)
    a = r.accounts.create
    s = Factory.create(:station,:owner=>a)

    assert r.accounts.count == 1
    assert s.accounts.count == 0
    assert Station.count == 2
    assert Station.active.count == 2
    assert Station.listed.count == 2 
    
    r.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})
    assert !r.active?
    assert a.active?,"account should be active until cache updated"

    assert Station.active.count == 1, "caches not updated station children should still be active"
    assert a.active?,"account should be active until cache updated"
    a.save!
    assert !a.active?,"account should be disabled"
    s.save
    assert Station.active.count == 0, "caches updated all stations disabled"
    
      
  end

end
