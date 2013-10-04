# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require Rails.root.join('db/schema').to_s
require 'rspec/rails'
require 'rspec/autorun'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
Dir[File.expand_path(File.join(File.dirname(__FILE__),'factoriessupport','**','*.rb'))].each {|f| require f}

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  include AccountHelpers

  config.use_transactional_fixtures = true

  config.order = "random"
end
