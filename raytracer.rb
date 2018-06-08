require_relative 'vector'
require_relative 'ray'
require_relative 'utility'
require 'parallel'

class RayTracer
  attr_accessor :width, :height, :data, :objects, :lights, :camera_position, :camera_angles, :clear_color, :scene_ambient

  FOCUS = Math.sqrt(3)

  PROCESSES_NUM = 16

  MAX_RAYS = 20
  REFLECTION_POWER_LIMIT = 0.00001

  def initialize(w, h)
    @width, @height = w, h
    @data = Array.new(@width * @height * 3, 0)
    @objects = []
    @lights = []

    @camera_position = Vector[0, 10, 2]
    @camera_angles = [0.5, 0, 0]
    @clear_color = [0, 0, 0]

    @scene_ambient = [0.1, 0.1, 0.1]

    @current_rays = 0
  end

  def camera_matrix
    @camera_matrix = Matrix[
      [Math.cos(@camera_angles[1]) * Math.cos(@camera_angles[2]), Math.cos(@camera_angles[0]) * Math.sin(@camera_angles[2]) + Math.sin(@camera_angles[0]) * Math.sin(@camera_angles[1]) * Math.cos(@camera_angles[2]), Math.sin(@camera_angles[0]) * Math.sin(@camera_angles[2]) - Math.cos(@camera_angles[0]) * Math.sin(@camera_angles[1]) * Math.cos(@camera_angles[2])],
      [-Math.cos(@camera_angles[1]) * Math.sin(@camera_angles[2]), Math.cos(@camera_angles[0]) * Math.cos(@camera_angles[2]) - Math.sin(@camera_angles[0]) * Math.sin(@camera_angles[1]) * Math.sin(@camera_angles[2]), Math.sin(@camera_angles[0]) * Math.cos(@camera_angles[2]) + Math.cos(@camera_angles[0]) * Math.sin(@camera_angles[1]) * Math.sin(@camera_angles[2])],
      [Math.sin(@camera_angles[1]), -Math.sin(@camera_angles[0]) * Math.cos(@camera_angles[1]), Math.cos(@camera_angles[0]) * Math.cos(@camera_angles[1])]
    ] unless @camera_matrix

    @camera_matrix
  end


  def render
    Timer("All") do
      GC.disable
      res = Parallel.map(0...height, in_processes: PROCESSES_NUM) do |y|
        t = []
        width.times do |x|
          t[x * 3 .. x * 3 + 2] = color2D(2.0 * x / @width - 1, 1 - 2.0 * y / @height)
        end
        t
      end

      @data = res.flatten
      GC.enable
    end
  end

  def trace(ray)
    return nil if @current_rays >= MAX_RAYS

    @current_rays += 1

    res = nil

    objects.each do |o|
      if (p = o.trace(ray))
        res = [o, p] if !res || res && (ray.start - p).r < (ray.start - res[1]).r
      end
    end

    @current_rays -= 1

    res
  end

  def color(ray)

    return [0, 0, 0] if ray.power < REFLECTION_POWER_LIMIT

    if (t = trace(ray))
      n = t[0].normal(t[1])

      # diffuse
      i = @scene_ambient.map { |x| x * t[0].material.ambient }

      @lights.each do |light|
        next if light.respond_to?(:position) && trace(Ray.new(t[1], -light.position))

        k = [n.inner_product(-light.position), 0].max if light.respond_to?(:position)
        diff = light.diffuse.map { |x| x * t[0].material.diffuse * k }

        k = [light.position.reflect(n).inner_product(-ray.dir), 0].max if light.respond_to?(:position)
        k **= t[0].material.shininess if k > 0
        spec = light.specular.map { |x| x * t[0].material.specular * k }

        i = i.zip(diff, spec).map { |x| x.reduce(:+) }
      end

      # reflection

      power = ray.power * t[0].material.reflection

      refl = color(Ray.new(t[1], ray.dir.reflect(n), power))

      res = t[0].material.color.zip(i).map { |x| x.reduce(:*) }

      return res.zip(refl).map { |x| x.reduce(:+) * ray.power }

    end

    @clear_color
  end

  def color2D(x, y)
    color(Ray.new(@camera_position, camera_matrix * Vector[x, y, -FOCUS]))
  end
end
