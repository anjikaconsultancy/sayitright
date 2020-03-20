object @user
node(:id) { |o| o.id.to_s }
attributes  :name, :username, :bio,:role, :status, :email, :email_hash, 
            :website, :accept_terms, :accept_marketing,:accept_marketing_from_partners, :language, :time_zone,
            :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip,
            :authentication_token,
            :header_source, :header_image_url,
            :avatar_source, :avatar_image_url

node(:path){|user| user_path(user.path)}            
            