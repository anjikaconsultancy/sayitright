object @system
node(:id) { |o| o.id.to_s }
attributes  :name,:version,:message,:warning
