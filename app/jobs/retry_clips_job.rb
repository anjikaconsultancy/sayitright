class RetryClipsJob < Struct.new(:status)
  def perform
    
    Clip.ne(status: :ready).each do |clip|
      clip.status = status.to_sym if status.present?
      clip.save
    end
      
  end
  
  def failure
  end
end