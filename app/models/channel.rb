class Channel     
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :site
  validates_presence_of :site_id 
  validates :featured, presence: true, numericality: { only_integer: true }

  # Connections authorised to post
  embeds_many :connections, as: :connectable

  
  # The unique id for everything which maps to url paths
  field :name, type: String  
  before_save do
    self.name = self.name.downcase.parameterize if self.name.present?
  end

  validates_uniqueness_of :name, case_sensitive: false, scope: :site_id, allow_blank: true
  validates_length_of :name, within: 4..40, allow_blank: true
  validates :name, format: { with: /\A^([[a-zA-Z0-9]][-]?)+$\z/, message: "must contain only letters, numbers or dashes" }, allow_blank: true

  validates_exclusion_of :name,  in: %w(edit new index),message: "that name is not allowed"

  # Path to this program
  def path
    name.presence || id
  end

  # Find by the path which can be id or name
  def self.find_from_path(id)
    if id.present?
      begin
        find(BSON::ObjectId(id)) rescue find_by(name: id)
      rescue Mongoid::Errors::DocumentNotFound
        find_by(name: id)
      end
    else
      raise ActionController::RoutingError.new('Bad User Id')
    end
  end

  # Settings
  field :title, type: String
  validates_presence_of :title
  
  field :summary, type: String

  field :content, type: String

  # Return something that can be used as a description snippet.
  def description
    summary.presence || (content.presence || "")[0..128]
  end

  field :publish_at, type: DateTime, default: ->{ created_at.presence || Time.now.utc }
  def publish_at=(t)
    self["publish_at"] = Chronic.parse(t.to_s).presence || publish_at.presence || Time.now.utc
  end

  # Status
  STATES = [:draft,:deleted,:disabled,:hidden,:published,'draft','deleted','disabled','hidden','published']   
  field :status, type: Symbol, default: :published
  validates_inclusion_of :status, in: Channel::STATES

  # Publicity
  field :public, type: Boolean, default: false
    
  # Featured priority on a site or channel
  field :featured, type: Integer, default: 0
  
  # Tags
  field :tags, type: Array, default: []
  def tags=(t)
    self["tags"] = t.split(/\s*,\s*/).reject(&:blank?).map(&:strip).uniq
  end
  def tags
    self["tags"].join(", ")
  end

  # For random queries
  field :random,  type: Float, default:0.0 
  before_save do
    self.random  = rand 
  end  
  
  # This will be set if preview has been uploaded
  field :preview_source, type: String
  before_save do
    if self.preview_source.present? and self.preview_source_changed?
      puts ENV['S3_BUCKET'] + "/channels/#{self.id}/preview"

      #Cant remember why we do the encode/decode step - clips do it I think something todo with fog
      source_bucket = URI.decode(URI.parse(URI.encode(self.preview_source.strip)).path.split('/')[1])  
      source_key = URI.decode(URI.parse(URI.encode(self.preview_source.strip)).path.split('/')[2..-1].join('/'))
      puts self.preview_source, source_bucket, source_key
      #This will throw an error and stop the save if there was a problem
      response = FogStorage.copy_object(source_bucket, source_key, ENV['S3_BUCKET'], "channels/#{self.id}/preview") 
      
      #Just set it to something else (add hash) so the same image can be imported again if needed
      self.preview_source = self.preview_source + '#ok'
    end
  end
  
  def preview_original
    "https://#{ENV['S3_CLOUD_FRONT']}/channels/#{self.id}/preview"+"?version=#{self.updated_at.to_i}" if self.preview_source.present?
  end
  
  def preview_url
    #Create a cdn url with last save date to do versioning
    "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:2000,height:2000,fit:clip/output=format:jpg/#{self.preview_original}" if self.preview_source.present?
    #'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/channels/#{self.id}/preview"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.preview_source.present?
    # 'https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/' + ERB::Util.url_encode("https://"+ENV['S3_BUCKET'] + "/channels/#{self.id}/preview"+"?version=#{self.updated_at.to_i}") + "/date/#{self.updated_at.to_i}" if self.preview_source.present?
  end
  
  # Get programs
  def programs
    Program.elem_match(allocations: { channel_id: self.id })  
  end

  # Programs for featured channels list (we cant do this in the template)
  def preview_programs
    Program.elem_match(allocations: { channel_id: self.id }).limit(6).entries  
  end

end
