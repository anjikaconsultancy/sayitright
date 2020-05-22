class Program
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection

  # Allocations - where this program is listed, together with the status this determines visibility.
  embeds_many :allocations
  accepts_nested_attributes_for :allocations, allow_destroy: true #, reject_if: proc {|a| a['site_id'].blank?}

  # Scope for content
  belongs_to :site
  validates_presence_of :site_id 

  # Owner
  belongs_to :user
  validates_presence_of :user_id  

  # The unique id for everything which maps to url paths
  field :name, type: String  
  before_save do
    self.name = self.name.downcase.parameterize if self.name.present?
  end
  validates_uniqueness_of :name, case_sensitive: false, scope: :site_id, allow_blank: true
  validates_length_of :name, within: 4..40, allow_blank: true
  validates :name, format: { with: /\A^([[a-zA-Z0-9]][-]?)+$\z/, message: "must contain only letters, numbers or dashes"}, allow_blank: true

  validates_exclusion_of :name,  in: %w(edit new index),message: "that name is not allowed"


  # Get the path to this program
  #
  # @param [Site] the current site to build paths against.
  # @return [String] the path to this program.
  def path(current_site = nil)
    # If the program is from an external site then build unique path based on site.
    if current_site.present? and current_site.id != site_id
      "#{site.host}~#{name.presence || id}"
    else
      name.presence || id
    end
  end

  # Find by the path which can be id or name
  def self.find_from_path(id,current_site = nil)
    if id.present?
      # If its a 'site_name' type path split and find its site
      if id.include? "~"
        parts = id.partition("~")
        program_id = parts[2]
        external_site = Site.find_by(host: parts[0])
      else
        program_id = id  
        external_site = nil
      end
      # First attempt to find by a bson id, if its not valid it will throw an error and try with the name
      begin
        if external_site
          external_site.programs.find(program_id) || external_site.programs.find_by(name: program_id)
        elsif current_site.present?
          current_site.programs.find(program_id) || current_site.programs.find_by_name_or_title(program_id)
        else
          find_by(name: program_id) # find(BSON::ObjectId(program_id))
        end
      rescue Mongoid::Errors::DocumentNotFound
        if external_site
          external_site.programs.find_by(name: program_id)
        elsif current_site.present?
          current_site.programs.find_by(name: program_id)
        else 
          find_by(name: program_id)
        end
      end
    else
      raise ActionController::RoutingError.new('Bad Program Id')
    end
  end

  def self.find_by_name_or_title program_id
    self.find_by(title: program_id) || self.find_by(name: program_id)
  end

  # Our content elements - we seem to need inverse of to make this work with the same base class
  embeds_many :segments, class_name: "Element", inverse_of: :segments
  embeds_many :fragments, class_name: "Element", inverse_of: :fragments

  accepts_nested_attributes_for :segments, allow_destroy: true
  accepts_nested_attributes_for :fragments, allow_destroy: true

  belongs_to :preview, class_name: "Clip"
  before_save do
    self[:preview_id] = segments.where(kind: :clip).first.try(:clip_id) || fragments.where(kind: :clip).first.try(:clip_id)
  end

  def preview_original
    preview.preview_original if preview_id.present?
  end

  def preview_url
    preview.preview_url if preview_id.present?
  end

  def image_url
    preview.image_url if preview_id.present?
  end  

  def preview_resize_url(width,height,fit)
    preview.preview_resize_url(width,height,fit) if preview_id.present?  
  end

  # If this is related to another url or content is copied from another site
  field :rel, type: String

  # Settings
  field :title, type: String
  validates_presence_of :title
  field :summary, type: String

  field :language, type: String, default: I18n.locale.to_sym

  # Return something that can be used as a description snippet.
  def description
    if summary.present?
      summary
    else
      description = ""
      fragments.each do |f|
        if f.content.present?
          description << f.content << " "
        end
      end
      description
    end
  end


  field :publish_at, type: DateTime, default: ->{ created_at.presence || Time.now.utc }
  def publish_at=(t)
    self["publish_at"] = Chronic.parse(t.to_s).presence || publish_at.presence || Time.now.utc
  end

  # Status - state which can be set depending on users permissions
  # :draft - still working on the program
  # :deleted - this has been deleted and awaiting cleanup
  # :disabled - this has been disabled by the ower, its not visible anywhere
  # :hidden - is available on the site at its path and search but hidden from allocation listings
  # :published - published and visible in listings
  STATES = [:draft,:deleted,:disabled,:hidden,:published,'draft','deleted','disabled','hidden','published']  
  field :status, type: Symbol, default: :published
  validates_inclusion_of :status, in: Program::STATES

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

end
