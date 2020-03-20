object false => :response

extends "presentation/base"

child @user do
  node(:id) { |o| o.id.to_s }
  attributes  :name, :bio,:role, :email_hash, 
              :website, :language, :time_zone, :avatar_image_url, :header_image_url, :avatar_image_original, :header_image_original

  node("is_#{@user.id}"){true}

  node(:path){|user| user_path(user.path)}
end

            