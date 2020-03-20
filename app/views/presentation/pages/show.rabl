object false => :response

extends "presentation/base"

child @page do
  node(:id) { |o| o.id.to_s }
  attributes :name, :title, :content

  node("is_#{@page.id}"){true}

  node(:description){|p| Sanitize.clean(p.description) }

  node(:path){|p| page_path(p.path)}    

end