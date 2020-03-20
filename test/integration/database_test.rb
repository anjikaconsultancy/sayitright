require 'test_helper'

class TestAccount
  include Mongoid::Document
  #do this safely, if there is a problem we can switch to owner_ids field and scope
  has_and_belongs_to_many :owners, :class_name=>"TestAccount", :inverse_of=>nil
  has_many :billed_accounts, :class_name=>"TestAccount", :inverse_of=>:owners, :foreign_key=>:owner_ids
  
  #field :owner_ids, :type=>Array, :default=>[]
  scope :billed_to, lambda {|owner| where(:owner_ids=>owner.id)}
end
 
class MongRoot
  include Mongoid::Document
  embeds_many :mong_embeddeds
  has_many :mong_relateds
  
  before_save do
    Thread.current[:calls] << "MD1"
  end

  before_save do
    Thread.current[:calls] << "MD2"
  end
  
  field :name
  validates_uniqueness_of :name, :allow_nil=>true
  
  field :adefault, :type=>Boolean, :default=>true
  
end

class MongRelated
  include Mongoid::Document
  belongs_to :mong_root
  before_save do
    Thread.current[:calls] << "MR1"
  end

  before_save do
    Thread.current[:calls] << "MR2"
  end
end

class MongEmbedded
  include Mongoid::Document
  embedded_in :mong_root
  before_save do
    Thread.current[:calls] << "ME1"
  end

  before_save do
    Thread.current[:calls] << "ME2"
  end
end


class MongInherited < MongRoot
  
  before_save do
    Thread.current[:calls] << "MI1"
  end

  before_save do
    Thread.current[:calls] << "MI2"
  end
end

class Tome
  include Mongoid::Document
  belongs_to :tome, :class_name=>"Tome"
  
  field :name
  field :tome_name #cache of referenced name
  
  before_save do
    self.tome_name = tome.name
  end
  
end

class MongArray
  include Mongoid::Document
  
  field :array, :type=>Array
end

class GenericTest < ActionController::IntegrationTest
  test "how model relations work" do
    o0 = TestAccount.create
    o1 = TestAccount.create
    a0 = TestAccount.create
    a1 = TestAccount.create
  
    

    a0.owners << [o0,o1]
    a1.owners = [o0]
    a1.save #note have to call save after = but not <<
    
    assert a0.owners.count == 2
    assert TestAccount.billed_to(o0).count == 2 ,"scoped"
    assert TestAccount.billed_to(o1).count == 1 ,"scoped"

    assert o0.billed_accounts.count == 2,"relation"
    assert o1.billed_accounts.count == 1,"relation"


     
    #DONT WORK THIS WAY YET
    #a2.billed_accounts << a4    
     
  end
  
  test "how saving related callbacks work" do
    #a bit messy but just testing call stack fires as expected
    Thread.current[:calls] = []
    d = MongRoot.create
    r = d.mong_relateds.create
    e = d.mong_embeddeds.create
    assert Thread.current[:calls]==["MD1","MD2","MR1","MR2","ME1","ME2"], "when we create or save individually they all get saved"

    Thread.current[:calls] = []
    d = MongRoot.new
    r = d.mong_relateds.build
    e = d.mong_embeddeds.build
    d.save
    assert Thread.current[:calls]==["MD1","MD2"], "when we build then save as one only root gets called"

    Thread.current[:calls] = []
    d = MongRoot.new
    r = d.mong_relateds.build
    e = d.mong_embeddeds.build
    e.save
    assert Thread.current[:calls]==["ME1","ME2","MD1","MD2"], "when we build then save from embedded child only child and parent gets called in that order"

    Thread.current[:calls] = []
    d = MongRoot.new
    r = d.mong_relateds.build
    e = d.mong_embeddeds.build
    r.save
    assert Thread.current[:calls]==["MR1","MR2"], "when we build then save from child only child gets called"
  
  end
  
  test "how saving inherited callbacks work" do
    Thread.current[:calls] = []
    m = MongInherited.create
    assert Thread.current[:calls]==["MD1","MD2","MI1","MI2"], "when create from inherited parent gets called first then child"
    assert MongInherited.first.class.name == "MongInherited" 
    assert MongRoot.first.class.name == "MongInherited", "class should still come back as inherited"

  end
  

  
  test "if item can reference itself" do
    t = Tome.new :name=>"me"
    t.tome = t
    t.save
    assert Tome.first == t
    assert Tome.first.tome_name == "me","name should cache itself"
    #puts "tome"
    
  end
  
  test "if validates uniqueness works across sti" do
    MongRoot.create :name=>"me"
    a = MongInherited.new :name=>"test"
    assert a.valid?, "should be able to create sti class with different name"
    b = MongInherited.new :name=>"me"
    assert !b.valid? ,"should not be able to create sti with same name as other class"
  end

  test "if defaults are inherited" do
    MongRoot.create :name=>"me"
    a = MongInherited.new :name=>"test"
    assert a.adefault ==true, "should inherit default true state"
  end


  test "if we can get field types" do
    t = Tome.new :name=>"me"

    assert t[:name].class == String, "is a string"
    
  end
  
  test "if array order is maintained" do
    a = MongArray.create :array=>[0,1,2,3,4,5]
    a = MongArray.first
    assert a.array[0]==0, "should maintain order after save"
    assert a.array[5]==5, "should maintain order after save"
  end

  
end