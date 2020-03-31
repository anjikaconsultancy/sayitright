# We run multiple independent sites on our system, Sites are  our namespace for all content and users on the system. 
# Sites are connected via networking and an OAuth system allows users to be authenticated across sites.

class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection

  # Status 
  # :live - live site
  # :deleted - this has been deleted and awaiting cleanup
  # :disabled - this has been disabled by the ower, its not visible anywhere
  STATES = [:live,:deleted,:disabled,'live','deleted','disabled']  
  # List for view, temporary workaround as rails bug needs both string and symbol in list for validation
  STATES_LIST = [:live,:deleted,:disabled]

  
  # Associations
  has_many    :clips
  has_many    :users
  has_many    :programs
  has_many    :channels
  has_many    :pages
  has_many    :themes # Themes this site owns

  embeds_many :connections, as: :connectable # Connections authorised to post
  embeds_many :domains, cascade_callbacks: true # Site has many domains, we need to cascade callbacks so the DNS is updated
  accepts_nested_attributes_for :domains, allow_destroy: true
  
  belongs_to :theme # Current theme

  belongs_to :network, class_name: "Site", inverse_of: :stations # Our parent network
  has_many   :stations, class_name: "Site", inverse_of: :network # Our child stations
  
  
  # We allow new sites to create a user so allow attributes
  accepts_nested_attributes_for :users

  
    
  # The unique id for this station and host on our domain
  field :host, :type=>String  
  validates_presence_of :host 
  validates_uniqueness_of :host, :case_sensitive => false
  validates_length_of :host, :within => 4..40 
  # validates_format_of :host, :with => /^([[:alnum:]][-]?)+$/ ,:message=>"must contain only letters, numbers or dashes"
  # validates_format_of :host, :with => /^[[:alpha:]]/,:message=>"must start with a letter"
  # validates_format_of :host, :with => /[[:alnum:]]$/,:message=>"must end with a letter or number"
  before_save do
    self.host = self.host.downcase.parameterize if self.host.present?
  end
  def to_param
    host
  end
         
  # Return a usable host for use in path construction
  def default_host
    "#{host}.#{ENV['DEFAULT_HOST']}"
  end

  # Return either the custom host, or default host if not available
  def custom_host
    #if domain
    #  domain
    #else
      default_host
    #end
  end

  # Get a url for this site
  def url
    "http://#{custom_host}"
  end

  # Find by the path which can be id or host
  def self.find_from_path(id)
    if id.present?
      begin
        find(BSON::ObjectId(id))
      rescue Mongoid::Errors::DocumentNotFound
        find_by(host: id)
      end
    else
      raise ActionController::RoutingError.new('Bad Site Id')
    end
  end

  def channels_for_role(role)
    role == :administrator ?  channels.in(status: [:draft, :hidden, :published]) : channels.where(status: :published)
  end

  # Site Package
  field :is_network, :type=>Boolean, :default=>false
  field :is_contributor, :type=>Boolean, :default=>false

  # Site Settings ===================================================================
  field :title, :type=>String  
  validates_presence_of :title 


  field :summary, :type=>String  
  def description
    summary.presence || ""
  end

  field :copyright, :type=>String  
  field :registerable, :type=>Boolean, :default=>false
  
  # Standard urls available to all pages & players so can link outside the system
  field :home_url,      :type=>String
  field :about_url,     :type=>String
  field :terms_url,     :type=>String
  field :privacy_url,   :type=>String
  field :contact_url,   :type=>String    
  field :help_url,      :type=>String    
  field :banner_url,    :type=>String    

  # For social links
  field :facebook_page_id,  :type=>String    
  field :twitter_id,        :type=>String    
  field :google_page_id,    :type=>String    


  # Status
  field :status, :type=>Symbol, :default=>:live
  
  # Billing Account
  field :billing_email,         type: String
  field :billing_contact,       type: String
  field :billing_company,       type: String
  field :billing_street,        type: String
  field :billing_locality,      type: String
  field :billing_city,          type: String
  field :billing_state,         type: String
  field :billing_post_code,     type: String
  field :billing_country,       type: String
  
  # Public email
  field :contact_email,         type: String

  # Google Analytics Id
  field :google_analytics_id,    :type=>String    

  # Site wide messaging
  field :message, :type=>String  
  field :warning, :type=>String  


  # This will be set if image has been uploaded
  field :logo_source, type: String
  field :icon_source, type: String
  field :background_source, type: String
  field :banner_source, type: String
  field :header_source, type: String

  before_save do
    [:logo,:icon,:background,:banner,:header].each do |i|
      #puts i,self["#{i}_source"].present?, self.send("#{i}_source_changed?")
      if self["#{i}_source"].present? and self.send("#{i}_source_changed?")
        #puts ENV['S3_BUCKET'] + "/sites/#{self.id}/#{i}"
  
        #Cant remember why we do the encode/decode step - clips do it I think something todo with fog
        source_bucket = URI.decode(URI.parse(URI.encode(self["#{i}_source"].strip)).path.split('/')[1])  
        source_key = URI.decode(URI.parse(URI.encode(self["#{i}_source"].strip)).path.split('/')[2..-1].join('/'))
        #puts self["#{i}_source"], source_bucket, source_key
        #This will throw an error and stop the save if there was a problem
        response = FogStorage.copy_object(source_bucket, source_key, ENV['S3_BUCKET'], "sites/#{self.id}/#{i}") 
        
        #Just set it to something else (add hash) so the same image can be imported again if needed
        self["#{i}_source"] = self["#{i}_source"] + '#ok'
      end
    end
  end
  
  def logo_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/sites/#{self.id}/logo"+"?version=#{self.updated_at.to_i}" if self.logo_source.present?
  end 
  
  def logo_image_url
    #Create a filestack cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:1000,height:1000,fit:clip/output=format:png/#{self.logo_image_original}" if self.logo_source.present?
    
    # This is through our heroku image proccessor cdn
    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/logo"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.logo_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/logo"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.logo_source.present?
  end
  
  def icon_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/sites/#{self.id}/icon"+"?version=#{self.updated_at.to_i}" if self.icon_source.present?
  end 
  
  def icon_image_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:960,height:960,fit:crop/output=format:png/#{self.icon_image_original}" if self.icon_source.present?

    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/icon"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.icon_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/icon"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.icon_source.present?
  end
  
  def background_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/sites/#{self.id}/background"+"?version=#{self.updated_at.to_i}" if self.background_source.present?
  end 
  
  def background_image_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:2000,height:2000,fit:clip/output=format:jpg/#{self.background_image_original}" if self.background_source.present?
    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/background"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.background_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/background"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.background_source.present?
  end
  
  def banner_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/sites/#{self.id}/banner"+"?version=#{self.updated_at.to_i}" if self.banner_source.present?
  end   
  
  def banner_image_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:1456,height:180,fit:crop/output=format:jpg/#{self.banner_image_original}" if self.banner_source.present?
    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/banner"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.banner_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/banner"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.banner_source.present?
  end
  
  def header_image_original
    "https://#{ENV['S3_CLOUD_FRONT']}/sites/#{self.id}/header"+"?version=#{self.updated_at.to_i}" if self.header_source.present?
  end   
  
  def header_image_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:2000,height:2000,fit:clip/output=format:jpg/#{self.header_image_original}" if self.header_source.present?
    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/header"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.header_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/sites/#{self.id}/header"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.header_source.present?
  end
end

