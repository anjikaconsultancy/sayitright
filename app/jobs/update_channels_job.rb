class UpdateChannelsJob # < Struct.new(:empty)
  def perform
    # Just re-save all channels so they will update themselves.
    Channel.all.each do |channel|
      puts "Updating Channel #{channel.id}"
      channel.save
    end
  end
  
  def failure
  end
end
