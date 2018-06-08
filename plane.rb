require_relative 'vector'

require_relative 'entity'

class Plane < Entity
    
  attr_accessor :position, :n
    
  def initialize(pos, n)
    super()
    @position, @n = pos, n
  end
    
  def normal(point)
    @n
  end
    
  def trace(ray)
    k = @n.inner_product(ray.dir)
        
    return nil if k.abs < AlmostZero
        
    b = @n.inner_product(ray.start - @position)
        
    t = -b / k
        
    return nil if t < AlmostZero
        
    t * ray.dir + ray.start
        
  end
end