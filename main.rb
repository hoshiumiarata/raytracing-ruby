require 'glfw3'
require 'opengl'

require_relative 'raytracer'
require_relative 'sphere'
require_relative 'plane'
require_relative 'light'

##########
raytracer = RayTracer.new(256, 256)

p = Plane.new(Vector[0, -3, 0], Vector[0, 1, 0])
p.material = Material.new([0.1, 0.1, 0.1], 0.4, 1, 0, 1, 0.7)
raytracer.objects << p

s = Sphere.new(Vector[0, 6, -15], 3)
s.material = Material.new([1, 0, 0], 0.4, 0.8, 0.5, 2, 0.1)
raytracer.objects << s

s = Sphere.new(Vector[3, 0, -15], 3)
s.material = Material.new([0, 0, 1], 0.4, 0.8, 0.5, 2, 0.1)
raytracer.objects << s

s = Sphere.new(Vector[-3, 0, -15], 3)
s.material = Material.new([0, 1, 0], 0.4, 0.8, 0.5, 2, 0.1)
raytracer.objects << s

raytracer.lights << DirectionalLight.new([0.5, 0.5, 0.5], [0.5, 0.5, 0.5], Vector[1, -1, -0.5].normalize)
##########

Glfw.init

window = Glfw::Window.new(800, 800, "Raytracer")

window.set_key_callback do |window, key, code, action, mods|
  window.should_close = true if key == Glfw::KEY_ESCAPE
end

window.set_close_callback do |window|
  window.should_close = true
end

window.make_context_current

GL.Enable(GL::TEXTURE_2D)
texture = GL.GenTextures(1)[0]
GL.BindTexture(GL::TEXTURE_2D, texture)
GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)

Thread.new { raytracer.render }

loop do
  Glfw.poll_events
  GL.Clear(GL::COLOR_BUFFER_BIT)

  GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGB, raytracer.width, raytracer.height, 0, GL::RGB, GL::FLOAT, raytracer.data)

  GL.Begin(GL::QUADS)
  GL.TexCoord2f(0, 0)
  GL.Vertex2f(-1, 1)

  GL.TexCoord2f(0, 1)
  GL.Vertex2f(-1, -1)

  GL.TexCoord2f(1, 1)
  GL.Vertex2f(1, -1)

  GL.TexCoord2f(1, 0)
  GL.Vertex2f(1, 1)
  GL.End

  window.swap_buffers
  break if window.should_close?
end

window.destroy
