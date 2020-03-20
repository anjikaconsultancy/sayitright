class FixClipsJob < Struct.new(:status)
  def perform
    
    Clip.or({status: :failed}, {encoded:false}).each do |clip|
      clip.status = status.to_sym if status.present?
      clip.save
    end
      
  end
  
  def failure
  end
end