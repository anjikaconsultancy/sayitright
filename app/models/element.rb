class Element
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection
  
  embedded_in :program, :inverse_of => :segments
  embedded_in :program, :inverse_of => :fragments

  # default_scope order_by([[:position, :asc]])
  default_scope { order(position: :asc) }
    
  # Order as elements array will not maintain it automatically, we use float as makes easy to re-order - just add the items positions of what its between and divide by 2
  field :position, type: Float, default: 0

  # Type of this element
  KINDS = [:text,:clip,:external]
  field :kind, type: Symbol, default: :text

  # Content or caption
  field :content, type: String

  # External URL
  field :url, type: String
  
  # Clip
  belongs_to :clip

end
