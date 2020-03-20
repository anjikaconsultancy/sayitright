collection @pages
node(:id) { |o| o.id.to_s }
attributes :title, :name

node(:path) do |page|
  page_path(page.path)
end

node(:description){|page| Sanitize.clean(page.description) }