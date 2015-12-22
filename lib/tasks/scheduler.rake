require "#{Rails.root}/app/helpers/static_pages_helper"
include StaticPagesHelper

desc "This task is called by the Heroku scheduler add-on"
task :update_dataset => :environment do
  puts "Updating orders database..."
  updateOrdersDatabase
  puts "Updating dataset..."
  updateDataset
  puts "done."
end

