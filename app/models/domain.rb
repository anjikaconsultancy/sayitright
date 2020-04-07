class Domain
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection

  embedded_in :site
      
  # Host name
  field :host, type: String
  validates :host, format: { with: /\A^[a-z][\.\-a-z0-9]*\.[a-z]+$\z/ }

  # Redirect path
  field :path, type: String

  # Validate the host is unique across the whole system
  validate do |domain|
    domain.errors.add :host, 'is already in use.' if Site.ne(_id: BSON::ObjectId(site.id)).elem_match(domains: { host: domain.host}).first
  end

  # Add the DNS entry on create
  #after_create do
  #  if Rails.env.production? or ENV['HEROKU_NAME'] = 'sirn-staging'
  #    heroku = Heroku::API.new
  #    heroku.post_domain(ENV['HEROKU_NAME'], host)   
  #  else
  #    # Add fake dns for testing
  #    FileUtils.mkpath "#{Rails.root.join("tmp","domains",Rails.env).to_s}/#{host}"
  #  end  
  #  puts "Adding Domain #{host}" unless Rails.env.production?
  #end
    
  # Remove DNS entry on destroy
  #after_destroy do
  #  if Rails.env.production? or ENV['HEROKU_NAME'] = 'sirn-staging'
  #    heroku = Heroku::API.new
  #    heroku.delete_domain(ENV['HEROKU_NAME'], host)  
  #  else
  #    # Remove fake dns entry
  #    FileUtils.rmdir "#{Rails.root.join("tmp","domains",Rails.env).to_s}/#{host}" 
  #  end   
  #  puts "Removing Domain #{host}" unless Rails.env.production?
  #end
  
end
