# frozen_string_literal: true

threads 1, 6
workers ENV["RACKAPP_PUMA_WORKERS"] || 4

app_dir = File.expand_path("../../..", __FILE__)
tmp_dir = "#{app_dir}/tmp"

# Default to production
rack_env = ENV["RACK_ENV"] || "production"
environment rack_env

# Set up socket location
bind "tcp://0.0.0.0:9292"

# Logging
stdout_redirect("#{app_dir}/log/puma.stdout.log",
                "#{app_dir}/log/puma.stderr.log", true)

# Set master PID and state locations
pidfile "#{tmp_dir}/puma.pid"
state_path "#{tmp_dir}/puma.state"
activate_control_app

on_worker_boot do
  require_relative "../../app"
end
