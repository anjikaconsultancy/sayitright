class Page
  include Mongoid::Document
  include Mongoid::Timestamps  
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :site
  validates_presence_of :site_id
  validates :featured, presence: true, numericality: { only_integer: true } 
   
  # The unique id for everything which maps to url paths
  field :name, type: String  
  before_save do
    self.name = self.name.downcase.parameterize if self.name.present?
  end
  validates_uniqueness_of :name, case_sensitive: false, scope: :site_id, allow_blank: true
  validates_length_of :name, within: 4..40, allow_blank: true
  # validates_format_of :name, with: /^([[:alnum:]][-]?)+$/ , allow_blank: true, message: "must contain only letters, numbers or dashes"
  # validates_format_of :name, with: /^[[:alpha:]]/, allow_blank: true, message: "must start with a letter"
  # validates_format_of :name, with: /[[:alnum:]]$/, allow_blank: true, message: "must end with a letter or number"
  validates_exclusion_of :name,  in: %w(edit new index),message: "that name is not allowed"

  # Path to this program
  def path
    name.presence || id
  end

  # Find by the path which can be id or name
  def self.find_from_path(id)
    if id.present?
      begin
        find(Moped::BSON::ObjectId(id))
      rescue Mongoid::Errors::DocumentNotFound,Moped::Errors::InvalidObjectId
        find_by(name: id)
      end
    else
      raise ActionController::RoutingError.new('Bad Page Id')
    end    
  end


  # Detail
  field :title, type: String
  field :summary, type: String
  field :content, type: String
  field :featured, type: Integer, default: 0

  # Return something that can be used as a description snippet.
  def description
    summary.presence || (content.presence || "")[0..128]
  end
    
  #:published, :hidden
  field :status, type: Symbol, default: :published
  
end