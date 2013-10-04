$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "accounting/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "accounting"
  s.version     = Accounting::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Accounting."
  s.description = "TODO: Description of Accounting."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency 'money'
  s.add_dependency 'rails', '~> 4.0.0'
  s.add_dependency 'state_machine'
  s.add_dependency 'uuid'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'factory_girl'
end
