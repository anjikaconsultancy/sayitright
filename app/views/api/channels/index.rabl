collection @channels

node(:id) { |o| o.id.to_s }
attributes :name, :title, :preview_url

node(:path){|p| channel_path(p.path)}
node(:publish_at){|this| this.publish_at.to_formatted_s(:long)}

node(:description){|p| Sanitize.clean(p.description) }
