object false => :response

extends "presentation/base"

child(:users) do
  child @users.items=>:user do |user|
    node(:id) { |o| o.id.to_s }    
    attributes :bio, :username, :name, :role, :status, :avatar_image_url, :header_image_url, :avatar_image_original, :header_image_original
    node(:path){|user| user_path(user.path)}
  end
  
  node(:count){@users.count}
  node(:page){@users.page}
  node(:pages){@users.pages}

  node(:next_page, :if=>lambda{|this|@users.pages > @users.page}){users_path(:page=>@users.page+1)}
  node(:previous_page, :if=>lambda{|this|@users.page > 1}){users_path(:page=>@users.page-1)}  

  
end