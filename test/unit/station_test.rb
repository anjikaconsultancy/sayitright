require 'test_helper'

class StationTest < ActiveSupport::TestCase
  def setup
    @network = Network.create
  end  

  test "we can create a station" do

    s = @network.stations.create(:name=>"station",:title=>"New Station")

    assert !s.valid?

    s = @network.stations.create(:host=>"newsite",:name=>"station",:title=>"New Station")
    assert s.valid?, s.errors.to_s

    s = Thing.search("type:Station")
    #puts s.inspect
    assert s["matches"]==1,"should be a station in search index, there was #{s["matches"]}"


    s = @network.stations.create(:host=>"newsite",:name=>"station",:title=>"New Station")
    assert !s.valid?, "should not allow duplicate hosts"

    s = @network.stations.create(:host=>"newsite2",:name=>"station",:title=>"New Station")
    assert s.valid?, s.errors.to_s
  end

  test "we cant create duplicate domains" do
    s = @network.stations.create(:host=>"newsite",:name=>"station",:title=>"New Station")
    
    d1 = s.domains.create(:host=>"www.domain1.com")
    assert d1.valid?, d1.errors.to_s    

    d2 = s.domains.create(:host=>"www.domain2.com")
    assert d2.valid?, d2.errors.to_s

    d2 = s.domains.create(:host=>"www.domain2.com")
    assert !d2.valid?, "should not allow duplicate domain in same site"

    s2 = @network.stations.create(:host=>"newsite2",:name=>"station",:title=>"New Site2")

    d2 = s2.domains.create(:host=>"www.domain2.com")
    assert !d2.valid?, "should not allow duplicate domain in different site"
  end

  test "we can destroy dns" do
    s = @network.stations.create(:host=>"newsite",:name=>"station",:title=>"New Station")

    s.domains.create(:host=>"www.deleteme1.com")
    s.domains.create(:host=>"www.deleteme2.com")
    assert s.domains.count==2, "should be 2 domains"
    assert Rails.cache.read("DNS_TEST_www.deleteme1.com") == true, "DNS test should exist"
    
    s.domains.first.destroy
    assert s.domains.count==1, "should be 1 domain"
    assert !Rails.cache.exist?("DNS_TEST_www.deleteme1.com"), "DNS test should be removed"

    s.domains.first.destroy

  end
  
  test "destroy site calls domain destroys" do
    s = @network.stations.create(:host=>"newsite",:name=>"station",:title=>"New Station")

    s.domains.create(:host=>"www.destroyme1.com")
    s.domains.create(:host=>"www.destroyme2.com")

    s.destroy
    
    assert !Rails.cache.exist?("DNS_TEST_www.destroyme1.com"), "DNS test should be removed"
    assert !Rails.cache.exist?("DNS_TEST_www.destroyme2.com"), "DNS test should be removed"

  end  

end
