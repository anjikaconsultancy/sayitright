object false => :response

extends "presentation/base"


child(:channels) do
  child @channels.items=>:channel do |channel|
    node(:id) { |o| o.id.to_s }
    attributes :name, :title, :preview_url, :preview_original

    node(:description){|p| Sanitize.clean(p.description).truncate(256, :separator => ' ', :omission => '...') }

    node(:publish_at) do |this| 
      {
        :full_date=>this.publish_at.strftime("%A, #{this.publish_at.day.ordinalize} %B %Y - %l:%M%p"),
        :short_date=>this.publish_at.strftime("%m/%d/%Y"),
        :short_time=>this.publish_at.strftime("%T")
      }
    end    
    node(:path) do |channel|
      channel_path(channel.path)
    end
    
  end
  
  node(:count){@channels.count}
  node(:page){@channels.page}
  node(:pages){@channels.pages}

  node(:next_page, :if=>lambda{|this|@channels.pages > @channels.page}){channels_path(:page=>@channels.page+1)}
  node(:previous_page, :if=>lambda{|this|@channels.page > 1}){channels_path(:page=>@channels.page-1)}
  
end