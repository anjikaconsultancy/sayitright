class UpdateClipsJob < Struct.new(:status)
  def perform
    # Just re-save all clips setting a previous status if given
    Clip.all.each do |clip|
      clip.status = status.to_sym if status.present?
      clip.save
    end
  end
  
  def failure
  end
end