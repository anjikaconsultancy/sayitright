collection @themes
node(:id) { |o| o.id.to_s }

attributes :title

node(:description){|p| Sanitize.clean(p.description) }
