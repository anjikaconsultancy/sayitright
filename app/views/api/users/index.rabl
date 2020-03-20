collection @users
node(:id) { |o| o.id.to_s }
attributes :bio, :name, :role, :status, :avatar_image_url

node(:path){|user| user_path(user.path)}
