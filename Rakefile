# frozen_string_literal: true

require "bundler"
require "active_record"
require "rake"
require "rspec"
require "git"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "sinatra/activerecord/rake"
require_relative "app"

task default: %i(rubocop spec)

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*spec.rb"
end

RuboCop::RakeTask.new

include ActiveRecord::Tasks
raw_conf = File.read(File.join(__dir__, "config", "config.yml"))
conf = YAML.load(ERB.new(raw_conf).result)
ActiveRecord::Base.configurations = conf["database"]

namespace :db do
  desc "create all the databases from config.yml"
  namespace :create do
    task(:all) do
      DatabaseTasks.create_all
    end
  end

  desc "drop all the databases from config.yml"
  namespace :drop do
    task(:all) do
      DatabaseTasks.drop_all
    end
  end

  desc "redo last migration"
  task redo: ["db:rollback", "db:migrate"]
end

desc "prepares everything for tests"
task :testup do
  system("rake db:migrate RACK_ENV=test")
  system("rake seed RACK_ENV=test")
end

desc "create release on github"
task(:release) do
  begin
    require "git"
    g = Git.open(File.dirname(__FILE__))
    new_tag = Gnc.version
    g.add_tag("v#{new_tag}")
    g.add(all: true)
    g.commit(":shipit: Releasing version #{new_tag}")
    g.push(tags: true)
  rescue Git::GitExecuteError => e
    puts e
  end
end

desc "populate seed data for tests"
task :seed do
  require_relative "db/seed"
end

desc "open an irb session preloaded with this library"
task :console do
  sh "irb -r pp -r ./app.rb"
end
