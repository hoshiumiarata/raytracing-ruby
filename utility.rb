require_relative 'material'

def Timer(name = "unnamed")
  t = Time.new
  yield
  puts "Timer #{name}: #{Time.new - t}"
end