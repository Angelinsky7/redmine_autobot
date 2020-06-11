namespace :autobot do

  desc <<-END_DESC
Find affected issues and update them
  END_DESC
  task :autobot => :environment do
    RedmineAutobot::Bot.execute()
  end

  desc <<-END_DESC
Find affected issues and preview them without updating
  END_DESC
  task :preview => :environment do
    RedmineAutobot::Bot.preview()
  end
end