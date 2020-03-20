require 'test_helper'

class NetworkTest < ActiveSupport::TestCase
  test "we can create a network" do
    n = Network.create
    assert n.valid?
  end
end
