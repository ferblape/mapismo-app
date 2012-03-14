#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

MapismoApp::Application.load_tasks

# Fake rake tasks for Semaphore
namespace :db do
  task :setup do
    true
  end
  namespace :test do
    task :prepare do
      true
    end
  end
end