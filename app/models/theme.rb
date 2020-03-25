class Theme
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps  
  include ActiveModel::ForbiddenAttributesProtection

  # Site that owns this theme
  belongs_to :site
  
  # Sites using this theme
  has_many :sites

  # Details
  field :title, type: String
  field :description, type: String
    
  #:public,:private,:network, :partners (partners is any site that you are paying for mm sub sites etc.)
  field :availability, type: Symbol, default: :private

  # Can someone copy and customize this template?
  field :editable, type: Boolean, default: false

  # The template code
  field :template, type: String

  # The template options and defaults
  field :options, type: Hash
  
  # What formats this supports
  field :formats, type: Array
  
  # Template Syntax
  field :syntax, type: Symbol, default: :mustache
  
end