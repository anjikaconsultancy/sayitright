require 'open-uri'

class EncodeClipJob < Struct.new(:clip_id)
  def perform
    @clip = Clip.find(clip_id)        

    if @clip.kind == :image
      
      # ruby open() does not like some urls??
      puts @clip.image_size_url
      # url = URI.parse(@clip.image_size_url)
      size = JSON.load(open(url))

      if size.present? and size['width'].present? and size['height'].present?
        @clip.width = size['width']
        @clip.height = size['height']
        @clip.encoded = true
        @clip.status = :ready
      else
        raise "Fetching Image Size Failed"
      end

      # We need to add a timestamp to ensure we dont hit the cache of an error from trying s3 too soon after import
      # size = JSON.load(open("#{@clip.base_cdn_url}/time/#{Time.now.to_i}/get/size/format.json"))
      
      # if size.present? and size['size'].present? and size['size']['width'].present? and size['size']['height'].present?
      #   @clip.width = size['size']['width']
      #   @clip.height = size['size']['height']
      #   @clip.encoded = true
      #   @clip.status = :ready
      # else
      #   raise "Fetching Image Size Failed"
      # end
      
      # Get url and send this to cloudinary    
      #upload = Cloudinary::Uploader.upload(FogStorage.get_object_url(ENV['S3_BUCKET'], "clips/#{@clip.id}/file", 2.hours.from_now),public_id:"clips_#{@clip.id}",invalidate:true,angle:"exif")
    
      # Store the response
      #if upload['secure_url'].present?
      #  @clip.cloudinary_version = upload['version']
      #  @clip.cloudinary_url = upload['url']
      #  @clip.cloudinary_secure_url = upload['secure_url']
      #  @clip.width = upload['width']
      #  @clip.height = upload['height']
      #  @clip.encoded = true        
      #  @clip.status = :ready
      #else
      #  raise "Cloudinary Upload Failed"
      #end
      
      @clip.save()
    elsif @clip.kind == :video
      job = Zencoder::Job.create({
        test: !(Rails.env.production? || Rails.env.staging?),
        input: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/file",
        outputs: [
          # H.264
          {
            label: "lq",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/lq.mp4",
            format: "mp4",
            video_bitrate: 200,
            audio_bitrate: 64,
            decoder_bitrate_cap: 200*1.5, #1.5x video
            decoder_buffer_size: 200*3.5, #3.5x video bitrate
            audio_sample_rate: 44100,
            width: 320,
            height: 180,
            h264_reference_frames: 1,
            h264_profile: "baseline",
            h264_level: 1.3,
            force_aac_profile:"aac-lc",
            forced_keyframe_rate: 0.1,
            denoise: "weak",
            max_frame_rate: 30
          },
          {
            label: "sq",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/sq.mp4",
            format: "mp4",
            video_bitrate: 400,
            audio_bitrate: 64,
            decoder_bitrate_cap: 400*1.5, #1.5x video
            decoder_buffer_size: 400*3.5, #3.5x video bitrate
            audio_sample_rate: 44100,
            width: 640,
            height: 360,
            h264_reference_frames: 1,
            h264_profile: "baseline",
            h264_level: 3,
            force_aac_profile:"he-aac",                       
            forced_keyframe_rate: 0.1,
            denoise: "weak",
            max_frame_rate: 30
          },
          {
            label: "mq",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/mq.mp4",
            format: "mp4",
            video_bitrate: 900,
            audio_bitrate: 96,
            decoder_bitrate_cap: 900*1.5,
            decoder_buffer_size: 900*3.5,
            audio_sample_rate: 44100,
            width: 960,
            height: 540,
            h264_reference_frames: "auto",
            h264_profile: "main",
            h264_level: 3.1, 
            force_aac_profile:"he-aac",                       
            forced_keyframe_rate: 0.1,
            denoise: "weak",
            max_frame_rate: 30
          },
          {
            label: "hq",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hq.mp4",      
            format: "mp4",
            video_bitrate: 1800,
            audio_bitrate: 128,
            decoder_bitrate_cap: 1800*1.5,
            decoder_buffer_size: 1800*3.5,
            audio_sample_rate: 44100,
            width: 1280,
            height: 720,
            h264_reference_frames: "auto",
            h264_profile: "main",
            h264_level: 3.1,
            force_aac_profile:"he-aac",                       
            forced_keyframe_rate: 0.1,
            denoise: "weak",
            max_frame_rate: 30,
            thumbnails:{
              base_url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/thumbnails/",
              filename: "{{padded-number}}",
              number: 8,
              format: "jpg",
              width: 1280,
              height:720
            }            
          },
          # Segmented TS transmuxed from H.264
          {
            label: "hls-aq",
            source: "lq",
            segment_video_snapshots: "true",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hls/aq/audio.m3u8",
            copy_audio: "true",
            skip_video: "true",
            #instant_play: true,
            type: "segmented",
            format: "aac",
            segment_video_snapshots: true
          },
          {
            label: "hls-lq",
            source: "lq",
            format: "ts",
            copy_audio: "true",
            copy_video: "true",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hls/lq/video.m3u8",
            #instant_play: true,
            type: "segmented"
          },
          {
            label: "hls-sq",
            source: "sq",
            format: "ts",
            copy_audio: "true",
            copy_video: "true",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hls/sq/video.m3u8",
            #instant_play: true,
            type: "segmented"
          },
          {
            label: "hls-mq",
            source: "mq",
            format: "ts",
            copy_audio: "true",
            copy_video: "true",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hls/mq/video.m3u8",
            #instant_play: true,
            type: "segmented"
          },
          {
            label: "hls-hq",
            source: "hq",
            format: "ts",
            copy_audio: "true",
            copy_video: "true",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hls/hq/video.m3u8",
            #instant_play: true,
            type: "segmented"
          },
          # HLS Playlist from segmented TS, Hight to Low order is important
          {
            streams: [
               {path: "hls/hq/video.m3u8",bandwidth: 2000,resolution: "1280x720",codecs: "avc1.77.31,mp4a.40.5"},
               {path: "hls/mq/video.m3u8",bandwidth: 1000,resolution: "960x540",codecs: "avc1.77.31,mp4a.40.5"},
               {path: "hls/sq/video.m3u8",bandwidth: 500,resolution: "640x360",codecs: "avc1.66.30,mp4a.40.5"},
               {path: "hls/lq/video.m3u8",bandwidth: 300,resolution: "320x180",codecs: "avc1.66.13,mp4a.40.2"},
               {path: "hls/aq/audio.m3u8",bandwidth: 64,codecs: "mp4a.40.2"},
            ],
            type: "playlist",
            url: "s3://#{ENV['S3_BUCKET']}/clips/#{@clip.id}/hls.m3u8"
          }             
        ]
      })
      if job.code.to_i == 201
        # The videos can take a while encoding so set an encoding status, another job will check for completion    
        @clip.zencoder_job_id = job.body['id'].to_i
        @clip.status = :encoding
        @clip.save()
      else
        raise "Zencoder Create Failed: #{job.code}"
      end      

    else
      raise "Encode Failed: Unsupported Kind"
    end
  end
  
  def failure
    @clip = Clip.find(clip_id)        
    # If the encode failed we still make the file available for download, just set encoded flag to false.
    @clip.status = :ready
    @clip.encoded = false

    @clip.save()
  end
end