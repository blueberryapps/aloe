$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aloe/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aloe"
  s.version     = Aloe::VERSION
  s.authors     = ["Jiri Zajpt"]
  s.email       = ["jzajpt@blueberry.cz"]
  s.homepage    = "https://github.com/blueberryapps/aloe"
  s.summary     = "TODO: Summary of Aloe."
  s.description = "TODO: Description of Aloe."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'money'
  s.add_dependency 'rails', '~> 4.0.0'
  s.add_dependency 'state_machine'
  s.add_dependency 'uuid'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'timecop'
end
