# We need this - http://stackoverflow.com/questions/4952522/error-when-trying-to-open-a-url-in-ruby-on-rails
require 'open-uri' 

class ImportClipJob < Struct.new(:clip_id)
  def perform
  
    @clip = Clip.find(clip_id)    

    # Try and extract the name from the source, just cleanup filepicker url for now
    if @clip.source.include? "_"
      @clip.name = @clip.source.partition("_")[2].rpartition(".")[0]
    else
      @clip.name = @clip.source.rpartition(".")[0]
    end

    info = FogStorage.head_object(@clip.source_bucket, @clip.source_key)
    
    if info.headers['Content-Type'].present?
      # Get the mime from content header
      @clip.mime = info.headers['Content-Type']
    else
      # Get the mime from extension
      @clip.mime = MIME::Types.type_for(@clip.source_key)[0]    
    end
    
    if @clip.mime.present?
      @clip.kind = MIME::Type.new(@clip.mime).media_type.to_sym
    else
      # Default to binary data stream
      @clip.mime = 'application/octet-stream'
      @clip.kind = :application
    end
    
    @clip.storage = info.headers['Content-Length'].to_i

    # Copy the file to our secure s3 bucket, this will raise an error if it fails
    response = FogStorage.copy_object(@clip.source_bucket, @clip.source_key, ENV['S3_BUCKET'], "clips/#{@clip.id}/file") 
    
    # Set the correct status to trigger encoders if needed
    if [:image,:video].include? @clip.kind
      @clip.status = :imported
    else
      @clip.encoded = false
      @clip.status = :ready
    end
    
    # Save and trigger next step
    @clip.save()
  end
  
  def failure
    @clip = Clip.find(clip_id)        
    @clip.status = :failed
    @clip.save()
  end
end