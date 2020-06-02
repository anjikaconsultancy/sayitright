collection @allocations, :xml_root=>"allocations" #, :object_root=>false

attributes :status

child :site=>"site" do
  node(:id) { |o| o.id.to_s }
  attributes :title, :link
end

child :channel=>"channel" do
  if @object[:channel].nil?
    node(:id) { |o| o.id.to_s }

    attributes :title, :link
  else
    node(:title) { 'Default' }

    attributes :title, :link
  end
end