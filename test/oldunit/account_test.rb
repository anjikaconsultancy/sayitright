require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "create without station fails" do
    a = Account.create
    assert !a.valid?
  end

  test "create with valid station works" do
    s =  Factory.create(:station)
    a = s.accounts.create
    assert a.valid?
  end

  test "account active states in root station" do
    s =  Factory.create(:station)
    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})
    a = s.accounts.create
    
    a.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})    
    assert a.active?, "station and account active"

    a.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})    
    assert !a.active?, "station active and account disabled"

    a.update_attributes({:enabled=>true,:disabled=>true,:locked=>false})    
    assert !a.active?, "station active and account disabled"

    a.update_attributes({:enabled=>true,:disabled=>false,:locked=>false}) 
    s.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})
    assert a.active?, "station disabled and account active but cache not updated"
    a.save  #update_attributes({:enabled=>true,:disabled=>false,:locked=>false})    
    assert !a.active?, "station disabled and account active"
  end
  
  test "account active scopes in root station" do
    s =  Factory.create(:station)
    
    s.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})
    a = s.accounts.create
    a.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})  
    assert s.accounts.active.count == 1,"station and account active"

    a.update_attributes({:enabled=>true,:disabled=>true,:locked=>false})   
    assert s.accounts.active.count == 0,"station active and account disabled"

    a.update_attributes({:enabled=>true,:disabled=>false,:locked=>false}) 
    s.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})
    assert s.accounts.active.count == 1,"station disabled and account enabled but cache not updated"
    a.save!
   
    assert s.accounts.active.count == 0,"station disabled and account active"
  end  


 test "active states in sub-station" do
    r = Factory.create(:station)
    o = r.accounts.create
    s = Factory.create(:station,:owner=>o)
    a = s.accounts.create
        
    r.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})    
    o.save!
    s.save!
    a.save!
    assert !a.active?,"disable root station should disable account state"
    assert s.accounts.active.count == 0,"disable root station should disable account scope"

    r.update_attributes({:enabled=>true,:disabled=>false,:locked=>false})    
    o.update_attributes({:enabled=>false,:disabled=>false,:locked=>false})    
    s.save!
    a.save!
    assert !a.active?,"disable owner account should disable account state"
    assert s.accounts.active.count == 0,"disable owner account should disable account scope"      
  end

  
end
