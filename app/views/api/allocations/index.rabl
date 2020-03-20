collection @allocations, :xml_root=>"allocations" #=>"allocations",:object_root=>false

child :site=>"site" do
  node(:id) { |o| o.id.to_s }
  attributes :title, :link
end
child :channel=>"channel" do
  node(:id) { |o| o.id.to_s }
  attributes :title, :link
end
