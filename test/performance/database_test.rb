require 'test_helper'
require 'rails/performance_test_help'


  class Something
    include Mongoid::Document

    field :owner,:type=>String
    field :owners,:type=>Array
  end
   
class DatabaseModelTest < ActionDispatch::PerformanceTest

  
  def setup
    1000.times do
      Something.create(:owner=>"one",:owners=>["two","three","four","five"])
    end  
  end
  test "test_or_query" do
    #a test to see if or query slows it down
    1000.times do
      Something.any_of(:owner=>"one",:owners=>"one").first
    end
  end
  test "test_in_query" do

    #find in array only
    1000.times do
      Something.where(:owners=>"two").first
    end
  end



end