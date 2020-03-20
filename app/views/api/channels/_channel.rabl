# We don't sent id's for new models, or create tries to find the nested embeds models
node(:id, :if=>@channel.persisted?) { |o| o.id.to_s }

attributes :title, :name, :content, :summary, :status, :public, :tags, :preview_source, :preview_url, :featured

node(:publish_at){|this| this.publish_at.to_formatted_s(:long)}

child :site, :if=>lambda { |a| a.has_site? } do
  node(:id) { |o| o.id.to_s }
  attributes :host, :title
end

node(:path){|p| channel_path(p.path)}   
