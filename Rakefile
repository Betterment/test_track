# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

if %w(development test).include? Rails.env
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  namespace :knapsack_pro do
    namespace :queue do
      desc "Run specs"
      task rspec: :environment do
        Rake::Task["spec"].invoke
      end
    end
  end

  task(:default).clear
  task default: %i(rubocop spec)
end
