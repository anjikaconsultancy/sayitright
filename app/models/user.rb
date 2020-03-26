class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps  
  include ActiveModel::ForbiddenAttributesProtection
    
  # Relations 
  belongs_to :site
  #validates_presence_of :site_id

  has_many :programs
  has_many :clips 


  # Role
  ROLES = [:user,:publisher,:moderator,:manager,:administrator,'user','publisher','moderator','manager','administrator']
  field :role, type: Symbol, default: :user
  # validates_inclusion_of :role, in: User::ROLES

  # Status
  # :active - all ok
  # :disabled - you may not login your profile and content is hidden 
  # :suspended - you may login but your profile and content is hidden (usually when you need to fix something)
  # :deleted - schedule for delete
  field :status, :type=>Symbol, default: :active
  # validates_inclusion_of :status, in: [:active,:disabled,:deleted,'active','disabled','deleted']

  # Username for profile
  field :username, type: String
  before_save do
    self.username = self.username.downcase if self.username.present?
  end

  # validates_length_of :username, minimum: 4, maximum: 20, allow_blank: true
  # validates_uniqueness_of :username, scope: :site_id, case_sensitive:  false, allow_blank: true
  # validates_format_of :username, with: /^([[:alnum:]][-]?)+$/, allow_blank: true, message: "must contain only letters, numbers or dashes"
  # validates_format_of :username, with: /^[[:alpha:]]/, allow_blank: true, message: "must start with a letter"
  # validates_format_of :username, with: /[[:alnum:]]$/, allow_blank: true, message: "must end with a letter or number"
  # validates_exclusion_of :username, in: %w(edit new index), message: "that name is not allowed"

  # Path to this user
  def path
    username.presence || id.to_s
  end

  # Find by the path which can be id or name
  def self.find_from_path(id)
    if id.present?
      begin
        find(Moped::BSON::ObjectId(id))
      rescue Mongoid::Errors::DocumentNotFound#,Moped::Errors::InvalidObjectId
        find_by(username: id)
      end
    else
      raise ActionController::RoutingError.new('Bad User Id')
    end
  end

  # Users display name
  field :name, type: String
  # validates_length_of :name, minimum: 4, maximum: 40
  # validates_presence_of :name  
  
  # A short bio
  field :bio, :type=>String
  # validates_length_of :bio, minimum: 4, maximum: 120, allow_blank: true

  # Users website
  field :website, type: String
  # validates_format_of :website, with: URI::regexp(%w(http https)), allow_blank: true


  # Marketing & Terms
  field :accept_marketing, type: Boolean, default: true
  field :accept_marketing_from_partners, type: Boolean, default: true
  field :accept_terms, type: Boolean
  # validates_acceptance_of :accept_terms, accept: true, allow_nil: false

  # Settings
  field :language, type: String, default: I18n.locale.to_sym
  field :time_zone, type: String, default: "Eastern Time (US & Canada)"
  

  # Hash of email address for gravatars etc.
  def email_hash
    Digest::MD5.hexdigest(email.downcase)
  end

  
  # Devise   
  devise :database_authenticatable, :registerable, :recoverable, :trackable,       
         authentication_keys: {email: true,site_id: true}
        #:request_keys, :validatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable           

  # before_save :ensure_authentication_token

  # Database authenticatable
  field :email,              type: String
  field :encrypted_password, type: String

  # Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  # Rememberable
  field :remember_created_at, type: Time

  # Trackable
  field :sign_in_count,      type: Integer
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Encryptable
  field :password_salt, type: String

  # Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  # Lockable
  field :failed_attempts, type: Integer # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  # Token authenticatable
  field :authentication_token, type: String

  # Invitable
  field :invitation_token, type: String
    
  # We remove default validatable to scope to site_id - note we use Devise.config_var to get the config
  # validates_presence_of   :email, if: :email_required?
  # validates_uniqueness_of :email, scope: :site_id, case_sensitive: (Devise.case_insensitive_keys != false), allow_blank: true, if: :email_changed?
  # validates_format_of     :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?

  # validates_presence_of     :password, if: :password_required?
  # validates_confirmation_of :password, if: :password_required?
  # validates_presence_of     :password_confirmation, on: :update, if: :password_required?
  # validates_length_of       :password, within: Devise.password_length, allow_blank: true


  # This will be set if image has been uploaded
  field :avatar_source, type: String
  field :header_source, type: String

  before_save do
    [:avatar,:header].each do |i|
      puts i,self["#{i}_source"].present?, self.send("#{i}_source_changed?")
      if self["#{i}_source"].present? and self.send("#{i}_source_changed?")
        puts ENV['S3_BUCKET'] + "/users/#{self.id}/#{i}"
  
        #Cant remember why we do the encode/decode step - clips do it I think something todo with fog
        # source_bucket = URI.decode(URI.parse(URI.encode(self["#{i}_source"].strip)).path.split('/')[1])  
        # source_key = URI.decode(URI.parse(URI.encode(self["#{i}_source"].strip)).path.split('/')[2..-1].join('/'))
        #puts self["#{i}_source"], source_bucket, source_key
        #This will throw an error and stop the save if there was a problem
        response = FogStorage.copy_object(source_bucket, source_key, ENV['S3_BUCKET'], "users/#{self.id}/#{i}") 
        
        #Just set it to something else (add hash) so the same image can be imported again if needed
        self["#{i}_source"] = self["#{i}_source"] + '#ok'
      end
    end
  end

  def avatar_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/users/#{self.id}/avatar"+"?version=#{self.updated_at.to_i}" if self.avatar_source.present?
  end 
  
  def avatar_image_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:960,height:960,fit:crop/output=format:png/#{self.avatar_image_original}" if self.avatar_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/users/#{self.id}/avatar") + "/date/#{self.updated_at.to_i}" if self.avatar_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/users/#{self.id}/avatar") + "/date/#{self.updated_at.to_i}" if self.avatar_source.present?
  end  
  
  def header_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/users/#{self.id}/header"+"?version=#{self.updated_at.to_i}" if self.header_source.present?
  end 
  
  def header_image_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:2000,height:2000,fit:clip/output=format:jpg/#{self.header_image_original}" if self.header_source.present?
    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/users/#{self.id}/header") + "/date/#{self.updated_at.to_i}" if self.header_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/users/#{self.id}/header") + "/date/#{self.updated_at.to_i}" if self.header_source.present?
  end  
  
  protected
  
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end 
  
end