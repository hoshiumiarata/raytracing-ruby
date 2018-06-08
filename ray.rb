class Ray
    
  attr_accessor :start, :dir, :power
    
  def initialize(start, dir, power = 1)
    @start, @dir, @power = start, dir, power
  end
    
end