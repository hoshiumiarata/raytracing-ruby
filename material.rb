class Material
    
  attr_accessor :color, :ambient, :diffuse, :specular, :shininess, :reflection
    
  def initialize(color = [1, 1, 1], ambient = 0.2, diffuse = 0.8, specular = 1, shininess = 1, reflection = 0)
    @color, @ambient, @diffuse, @specular, @shininess, @reflection = color, ambient, diffuse, specular, shininess, reflection
  end
    
end
