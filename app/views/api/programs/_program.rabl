# We don't sent id's for new models, or create tries to find the nested embeds models
node(:id, :if=>@program.persisted?) { |o| o.id.to_s }

attributes :language, :title, :name, :summary, :status, :tags

node(:publish_at){|this| this.publish_at.to_formatted_s(:long)}


child :allocations do
  node(:id, :if=>@program.persisted?) { |o| o.id.to_s }

  attributes :status
  
  node do  |allocation|
    #node(:link){ root_url(:host=>allocation.site.host) }
    child :site, :if=>lambda { |a| a.has_site? } do 
      node(:id) { |o| o.id.to_s }
      attributes :title
      node(:link){ root_url(:host=>allocation.site.host) }
    end
    child :channel, :if=>lambda { |a| a.has_channel? } do |c|
      node(:id) { |o| o.id.to_s }
      attributes :title
      node(:link){ channel_url(c.path,:host=>allocation.site.host) }        
    end
  
  end
end

child :segments => "segments" do |s|
  node(:id, :if=>@program.persisted?) { |o| o.id.to_s }
  attribute :position, :content, :kind, :url
  child :clip, :if=>lambda { |a| a.has_clip? } do 
    node(:id) { |o| o.id.to_s }
    attributes :kind,:encoded,:status,:base_url, :preview_url
  end  
end

child :fragments => "fragments" do |f|
  node(:id, :if=>@program.persisted?) { |o| o.id.to_s }
  attribute :position, :kind, :url
  
  node :content do |o|
    sanitize = { :elements => ['a', 'p','h3','b','i','u','strong','em','ol','ul','li','strike','blockquote','pre','sub','sup'], :attributes => {'a' => ['href', 'title']}, :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}}}
    Sanitize.clean(o.content,sanitize)
  end

  child :clip, :if=>lambda { |a| a.has_clip? } do 
    node(:id) { |o| o.id.to_s }
    attributes :kind,:encoded,:status,:base_url, :preview_url
  end 
  
end

node(:path){|p| program_path(p.path)}   