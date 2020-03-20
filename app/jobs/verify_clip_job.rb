class VerifyClipJob < Struct.new(:clip_id)
  def perform
  
    @clip = Clip.find(clip_id)    

    # Wait for this zencoder job to finish the get info
    if @clip.zencoder_job_id.present?
      job = Zencoder::Job.progress(@clip.zencoder_job_id)
      if job.code.to_i == 200
        @clip.zencoder_status = job.body['state']
        # The videos can take a while encoding so set an encoding status, another job will check for completion    
        case @clip.zencoder_status 
        when "finished"
          @clip.zencoder_progress = 100

          details = Zencoder::Job.details(@clip.zencoder_job_id)
          if details.code.to_i == 200
            
            # Grab the duration from the input video, we might need to use output to get size to account for non square input pixels but outputs did not always have a size?
            @clip.duration = details.body['job']['input_media_file']['duration_in_ms'].to_i
            @clip.width = details.body['job']['input_media_file']['width'].to_i
            @clip.height = details.body['job']['input_media_file']['height'].to_i
            @clip.status = :ready
            @clip.encoded = true
              
            # Send the first thumbnail to cloudinary
            #upload = Cloudinary::Uploader.upload(FogStorage.get_object_url(ENV['S3_BUCKET'], "clips/#{@clip.id}/thumbnails/0000.jpg", 2.hours.from_now),public_id:"clips_#{@clip.id}")
          
            # Store the response also grab the size so we can calculate aspect ration later
            #if upload['secure_url'].present?
            #  @clip.cloudinary_version = upload['version']
            #  @clip.cloudinary_url = upload['url']
            #  @clip.cloudinary_secure_url = upload['secure_url']
            #  @clip.width = upload['width'].to_i
            #  @clip.height = upload['height'].to_i
            #  @clip.status = :ready
            #  @clip.encoded = true
            #else
            #  raise "Cloudinary Upload Failed"
            #end
          else
            raise "Zencoder Details Failed: #{job.code}"            
          end
        when "failed","cancelled"
          # If the job failed then set encoded to false but still mark the file as ready so it can be retried or downloaded if it was an unsupported file
          @clip.status = :ready
          @clip.encoded = false
        when "processing"
          @clip.zencoder_progress = job.body['progress']      
        end
        #save will trigger a new verify if we are still waiting
        @clip.save
      else
        raise "Zencoder Progress Failed: #{job.code}"      
      end
    else
      raise "Verify Failed: Unsupported"
    end
  end
  
  def failure
    @clip = Clip.find(clip_id)        
    @clip.status = :ready
    @clip.encoded = false
    @clip.save()
  end
end