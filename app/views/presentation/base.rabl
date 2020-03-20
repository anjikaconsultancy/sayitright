child({current_site.network=>:network},:if=>lambda { |this| current_site.has_network?}) do
  node(:id) { |this| this.id.to_s }
  attributes :host, :title, :icon_image_url, :icon_image_original, :logo_image_url, :logo_image_original
  node(:url) do |this|
    root_url(:host => this.custom_host)
  end
end


child request=> :request do
  node(:cdn_path){"https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/"}
  node(:action){action_name}
  node(:controller){controller_name}
  node("is_#{controller_name}"){true}
  node("is_#{controller_name}_#{action_name}"){true}
  node(:host){|r|r.host}
  node(:path){|r|r.path.split(".")[0]}
  node(:active_path){|r|
    path=r.path.split(".")[0]
    if path== "/"
      "/index"
    else
      path
    end
  }
  
  node(:query) do |r|
    {
    search: r.params[:search],
    tags: r.params[:tags],
    title: r.params[:title],
    summary: r.params[:summary],
  }
  end
  
  node(:format){|r|r.params[:format]}  
  
  node(:request_time){@request_time}
  # We calculate the processed time as late as we can which is now, so still doesnt include the template render
  node(:processing_time){Time.now-@request_time}
end

child current_site=>:site do
  node(:id) { |o| o.id.to_s }
  attributes :host, :title, :is_network, :is_contributor

  node("is_#{current_site.id}"){true}
  
  node(:sign_in_path){new_user_session_path}
  node(:sign_up_path, :if=>current_site.registerable){new_user_registration_path}

  attributes :home_url, :if=>current_site.home_url.present?
  attributes :about_url, :if=>current_site.about_url.present?
  attributes :terms_url, :if=>current_site.terms_url.present?
  attributes :privacy_url, :if=>current_site.privacy_url.present?
  attributes :contact_url, :if=>current_site.contact_url.present?   
  attributes :help_url, :if=>current_site.help_url.present? 
  attributes :banner_url, :if=>current_site.banner_url.present? 

  attributes :icon_image_original, :icon_image_url, :logo_image_original, :logo_image_url, :background_image_url, :background_image_original, :banner_image_url, :banner_image_original, :header_image_url, :header_image_original

  attributes :facebook_page_id, :if=>current_site.facebook_page_id.present?
  attributes :twitter_id, :if=>current_site.twitter_id.present?
  attributes :google_page_id, :if=>current_site.google_page_id.present?
    
  node(:description, :if=>current_site.description.present?){|p| Sanitize.clean(p.description).truncate(128, :separator => ' ', :omission => '...') }
  node(:summary){|p| Sanitize.clean(p.summary) }

  node(:copyright){|p| Sanitize.clean(p.copyright) }

end

node(:theme) do
  {
    path: "//#{ENV[params[:nocache].present? ? "S3_BUCKET" : "S3_CLOUD_FRONT"]}/themes/#{current_site.theme_id.presence || ENV['DEFAULT_THEME_ID']}",
    version: current_site.theme.try(:updated_at) || 0
  }
end

child current_site.pages.where(status: :published,:featured.gt => 0).order_by([:featured,:desc]).limit(12).entries =>:featured_pages do
  node(:id) { |o| o.id.to_s }
  attributes :name, :title, :status
  node(:path){|page| page_path(page.path)}
end

child current_site.channels.where(status: :published,:featured.gt => 0).order_by([:featured,:desc]).limit(12).entries =>:featured_channels do
    node(:id) { |o| o.id.to_s }
    attributes :name, :title, :status, :tags, :preview_url, :preview_original

    node(:description){|p| Sanitize.clean(p.description).truncate(128, :separator => ' ', :omission => '...') }

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

child current_site.stations.where(status: :live).order_by([:created_at,:desc]).limit(12).entries =>:featured_stations do
    node(:id) { |o| o.id.to_s }
    attributes :name, :title, :host, :icon_image_url, :icon_image_original, :logo_image_url, :logo_image_original

    node(:url) do |this|
      root_url(:host => this.custom_host, protocol: 'http')
    end    
    
    node(:description){|p| Sanitize.clean(p.description).truncate(128, :separator => ' ', :omission => '...') }
end