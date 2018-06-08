class Light
    
  attr_accessor :diffuse, :specular
    
  def initialize(diffuse, specular)
    @diffuse, @specular = diffuse, specular
  end
    
end


class DirectionalLight < Light
    
  attr_accessor :position
    
  def initialize(diffuse, specular, position)
    super(diffuse, specular)
        
    @position = position
  end

end