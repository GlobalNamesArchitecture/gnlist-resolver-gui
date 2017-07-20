# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/bin/"
  add_filter "/coverage/"
end

require "rack/test"
require "capybara"
require "capybara/rspec"
require "capybara/dsl"
require "capybara/webkit"
require "byebug"
require "factory_girl"
require_relative "support/helpers"
require_relative "factories"

ENV["RACK_ENV"] = "test"
require_relative "../app.rb"

Capybara.javascript_driver = :webkit
Capybara.app = Gnlr::App

RSpec.configure do |c|
  c.include Capybara::DSL
  c.include FactoryGirl::Syntax::Methods
end
