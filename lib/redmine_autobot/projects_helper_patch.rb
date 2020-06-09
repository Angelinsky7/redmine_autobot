require_dependency "projects_helper"

module RedmineAutobot
  module ProjectsHelperPatch
    def self.included(base)
      base.class_eval do

        def project_settings_tabs_with_redmine_autobot
          tabs = project_settings_tabs_without_redmine_autobot

          if User.current.allowed_to?(:redmine_autobot_manage, @project)
            options = {:name => 'activities', :action => :manage_project_activities, :partial => 'projects/settings/activities', :label => :enumeration_activities}
            index = tabs.index(options)
          end

          if index
             tabs.insert(index, {:name => 'autobot', :action => :edit_autobots, :partial => 'projects/settings/autobot_edit', :label => :redmine_autobot_menu_label})
             tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
          end
        
          return(tabs)
        end
        alias_method :project_settings_tabs_without_redmine_autobot, :project_settings_tabs
        alias_method :project_settings_tabs, :project_settings_tabs_with_redmine_autobot

      end
    end
  end
end