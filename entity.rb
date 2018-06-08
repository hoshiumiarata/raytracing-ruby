require_relative 'material'

class Entity
    
  attr_accessor :material
    
  AlmostZero = 0.000001
    
  def initialize
    @material = Material.new
  end
    
end