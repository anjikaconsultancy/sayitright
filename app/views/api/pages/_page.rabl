# We don't sent id's for new models, or create tries to find the nested embeds models
node(:id, :if=>@page.persisted?) { |o| o.id.to_s }

attributes :name,:title, :summary,:content,:status, :featured

child :site, :if=>lambda { |a| a.has_site? } do
  node(:id) { |o| o.id.to_s }
  attributes :host, :title
end
