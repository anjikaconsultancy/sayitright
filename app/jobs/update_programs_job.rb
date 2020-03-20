class UpdateProgramsJob # < Struct.new(:empty)
  def perform
    # Just re-save all programs they will update themselves
    Program.all.each do |program|
      puts "Updating Program #{program.id}"
      program.save
    end
  end
  
  def failure
  end
end