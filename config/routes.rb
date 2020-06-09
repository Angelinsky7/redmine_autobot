# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# get 'autobot', :controller => :redmine_autobot, :action => :index, :as => :redmine_autobot_index
post 'autobots/:id', :controller => :autobot, :action => :edit, :as => :autobot_edit