object false => :response

extends "presentation/base"


child(:stations) do
  child @stations.items=>:station do |channel|
    node(:id) { |o| o.id.to_s }
    attributes :name, :title, :host, :is_contributor, :icon_image_url, :logo_image_url, :icon_image_origianl, :logo_image_original

    node(:url) do |this|
      root_url(:host => this.custom_host, protocol: 'http')
    end    
    
    node(:description){|p| Sanitize.clean(p.description).truncate(128, :separator => ' ', :omission => '...') }
    
  end
  
  node(:count){@stations.count}
  node(:page){@stations.page}
  node(:pages){@stations.pages}

  node(:next_page, :if=>lambda{|this|@stations.pages > @stations.page}){stations_path(:page=>@stations.page+1)}
  node(:previous_page, :if=>lambda{|this|@stations.page > 1}){stations_path(:page=>@stations.page-1)}
  
end