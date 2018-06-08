require 'matrix'

class Vector
  def -@
    map { |x| -x }
  end

  def reflect(n)
    self - n * 2 * self.inner_product(n)
  end
end