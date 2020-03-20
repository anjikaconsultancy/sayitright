require 'test_helper'

class ThingTest < ActiveSupport::TestCase
  def setup
    @network = Network.create
    @station = @network.stations.create(:host=>"newsite",:name=>"station",:title=>"New Site")
  end
  
  test "we can create a generic thing" do
    t = @station.things.build
    assert t.valid?, t.errors.to_s
  end

  test "valid thing names" do
    t = @station.things.build(:name=>"srt")
    assert !t.valid?, "should be too short"
    t = @station.things.build(:name=>"soo@99s")
    assert t.valid?, "should be converted to good letters"
    t = @station.things.build(:name=>"0number")
    assert !t.valid?, "should not allow leading number"
    t = @station.things.build(:name=>"0number")
    assert !t.valid?, "should not allow leading number"
    t = @station.things.build(:name=>"-number")
    assert t.valid?, "should remove leading dash"
    t = @station.things.build(:name=>"number-")
    assert t.valid?, "should remove ending dash"
    t = @station.things.build(:name=>"num_ber")
    assert !t.valid?, "should not allow underscore"
    t = @station.things.build(:name=>"num--ber")
    assert t.valid?, "should remove duplicate dashed"

    t = @station.things.create(:name=>"num-ber-99")
    assert t.valid?, t.errors.to_s

    t = @station.things.create(:name=>"num-ber-99")
    assert !t.valid?, "should not allow duplicates in this station"

    @station = @network.stations.create(:host=>"anothersite",:name=>"station",:title=>"New Site")
    
    t = @station.things.create(:name=>"num-ber-99")
    assert t.valid?, "should allow duplicates in another station"
  end

  test "we can search things" do
    t1 = @station.things.create(:name=>"Item1",:content=>"item 1")    
    t2 = @station.things.create(:name=>"Item2",:content=>"item 2")    
    t3 = @station.things.create(:name=>"Item3",:content=>"item 3")    

    s = Thing.search()
    #puts s.inspect
    assert s["matches"]==4,"should be 4 things there was #{s["matches"]}" #station is the extra 1
    assert Thing.search("name:item2")["matches"]==1,"should be 1 thing there was #{s["matches"]}"
    
    t3.listed = false
    t3.save
    
    s = Thing.search()
    assert s["matches"]==3,"should be 3 things there was #{s["matches"]}" #test we can delete an index station is the extra 1

    t2.destroy_index    
    t3.destroy_index  #this should be deleted but hopefully should not throw an error
    s = Thing.search()
    assert s["matches"]==2,"should be 2 things there was #{s["matches"]}" #test we can delete an index station is the extra 1

  end

end