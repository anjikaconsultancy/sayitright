object @site
node(:id) { |o| o.id.to_s }
attributes  :host, :title, :summary,:copyright,:registerable,
            :home_url,:about_url,:terms_url,:privacy_url,:contact_url,:help_url,:banner_url,:contact_email,
            :logo_source, :logo_image_url,
            :icon_source, :icon_image_url,
            :background_source, :background_image_url,
            :header_source, :header_image_url,
            :banner_source, :banner_image_url,
            :facebook_page_id,:twitter_id,:google_page_id,
            :google_analytics_id,:message,:warning

child :theme, :if=>lambda { |a| a.has_theme? } do
  node(:id) { |o| o.id.to_s }
end

child :domains do
  # We don't sent id's for new models, or create tries to find the nested embeds models
  node(:id, :if=>@site.persisted?) { |o| o.id.to_s }

  attributes :host,:path  
end