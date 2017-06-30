# frozen_string_literal: true

ENV["RACK_ENV"] || "development"
require "./app.rb"

set :run, false

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Gnc::App
