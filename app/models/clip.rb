class Clip
  include Mongoid::Document
  include Mongoid::Timestamps
    
  # Version for encoding updates
  field :version, type: Integer, default: 0   

  # Status for running jobs - :created,:importing,:encoding,:ready,:failed
  field :status, type: Symbol, default: :created  
  
  # There is no success status for encodes, we simply set the status to ready and encoded to false for failed
  # This means we still store the files and make them available for download and can re-encode when we can
  field :encoded, type: Boolean, default: false
    
  # Owner
  belongs_to :user
  belongs_to :site  
    
  # Original file name
  field :name, type: String

  # The source to import, must currently be an S3 url - do not store encoded urls or fog.io trys to encode them again.
  field :source, type: String
  
  # Validates that this is a valid S3 url, note that we need to encode before we pass to parse or urls with spaces etc fail.
  validates_each :source, on: :create do |record, attr, value|
    begin
      # record.errors.add attr, 'Source file must be an S3 url.' unless URI.parse(URI.encode(value.strip)).host == 's3.amazonaws.com'
    rescue URI::InvalidURIError
      record.errors.add attr, 'Source file must be a valid S3 url.'
    end
  end
  
  def source_bucket
    # Parse for the bucket, we need to make sure fog gets the decoded url as it encodes again!
    # URI.decode(URI.parse(URI.encode(self.source.strip)).path.split('/')[1]) if self.source
  end
  
  def source_key
    # URI.decode(URI.parse(URI.encode(self.source.strip)).path.split('/')[2..-1].join('/')) if self.source
  end

  def base_url
    "https://"+ENV['S3_BUCKET'] + "/clips/#{self.id}" 
  end
  
  def base_cdn_url
    "https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/#{ERB::Util.url_encode(self.base_url + "/file")}/date/#{self.updated_at.to_i}"
    #"https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/#{ERB::Util.url_encode(self.base_url + "/file")}/date/#{self.updated_at.to_i}"  
  end
  
  def original_url
    "https://#{ENV['S3_CLOUD_FRONT']}/clips/#{self.id}/file?version=#{self.updated_at.to_i}"
  end
  
  # TODO - the encoded state does not look like it is set so use ready for now?
  def preview_original

    if self.status == :ready #and self.encoded
      if self.kind == :image
        "https://#{ENV['S3_CLOUD_FRONT']}/clips/#{self.id}/file?version=#{self.updated_at.to_i}"

        #"https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/" + ERB::Util.url_encode(self.base_url + "/file") + "/date/#{self.updated_at.to_i}"
        # "https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/" + ERB::Util.url_encode(self.base_url + "/file") + "/date/#{self.updated_at.to_i}"
      elsif self.kind == :video
        "https://#{ENV['S3_CLOUD_FRONT']}/clips/#{self.id}/thumbnails/0000.jpg?version=#{self.updated_at.to_i}"
        
        #"https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/" + ERB::Util.url_encode(self.base_url + "/thumbnails/0000.jpg") + "/date/#{self.updated_at.to_i}"
        # "https://d1vg9fjywzevj0.cloudfront.net/user/sayitright/s3/" + ERB::Util.url_encode(self.base_url + "/thumbnails/0000.jpg") + "/date/#{self.updated_at.to_i}"
      end
    end    
  end
  def preview_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:960,height:540,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end

  def image_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/output=format:jpg/#{self.preview_original}"
    end
  end

  def image_size_url
    # Return json with width & height
    if self.kind == :image
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/imagesize/#{self.original_url}"
    end
  end

  def preview_resize_url(width,height,fit)
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:#{width},height:#{height},fit:#{fit}/output=format:jpg/#{self.preview_original}"
    end
  end  

  def limit_960_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:960,fit:max/output=format:jpg/#{self.preview_original}"
    end
  end

  def limit_1920_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:1920,fit:max/output=format:jpg/#{self.preview_original}"
    end
  end


  def crop_160x90_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:160,height:90,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end
  
  def crop_320x180_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:320,height:180,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end

  def crop_480x270_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:480,height:270,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end

  def crop_640x360_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:640,height:360,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end

  def crop_1280x720_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:1280,height:720,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end

  def crop_1920x1080_url
    if self.status == :ready and (self.kind == :image or self.kind == :video) #and self.encoded
      "https://cdn.filestackcontent.com/#{ENV['FILEPICKER_API_KEY']}/resize=width:1920,height:1080,fit:crop/output=format:jpg/#{self.preview_original}"
    end
  end

  
  # Mime and kind of original file it is important to set this so we know what to encode and display
  field :mime, type: String, default: 'application/octet-stream'
  field :kind, type: Symbol, default: :application
            
  # S3 storage of original file used for the basis of all billing
  field :storage, type: Integer, default: 0

  # File info from encoders
  field :width, type: Integer, default: 0 
  field :height, type: Integer, default: 0 
  field :duration, type: Integer, default: 0 #in ms

  # Cloudinary results
  #field :cloudinary_version, type: String
  #field :cloudinary_url, type: String
  #field :cloudinary_secure_url, type: String      

  # Zencoder Job Id
  field :zencoder_job_id, type: String
  field :zencoder_progress, type: Integer
  field :zencoder_status, type: String, default: "unknown"

  # When we save this, trigger any processing that needs doing
  after_save :process

  # Start the importers or encoder depending on the status
  # Setting a current status and re-saving a clip is enough to trigger next step 
  def process
    case status
    when :created
      Delayed::Job.enqueue(ImportClipJob.new(self.id.to_s))
    when :imported
      Delayed::Job.enqueue(EncodeClipJob.new(self.id.to_s))
    when :encoding
      # This is delayed, and it retrys until its encoded
      Delayed::Job.enqueue(VerifyClipJob.new(self.id.to_s),run_at: 60.seconds.from_now)
    end    
  end
  
end