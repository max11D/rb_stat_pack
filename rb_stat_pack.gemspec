files = []
depth = 4
depth.times do |n|
  p = "./lib"
  (n+1).times { p << "/*" }
  files += Dir.glob("#{p}.rb")
end

puts files

Gem::Specification.new do |s|
    s.name        = 'rb_stat_pack'
    s.version     = '0.0.0'
    s.date        = '2018-12-24'
    s.summary     = "Ruby Statistical Package"
    s.description = "A basic statistical package for social sciences"
    s.authors     = ["Maksim Mikityanskiy"]
    s.email       = 'mmik005@gmail.com'
    s.files       = files.map {|f| f.gsub("./", "") }
    s.license     = 'MIT'
    s.homepage    = "https://www.github.com/max11d/rb_stat_pack"
  end