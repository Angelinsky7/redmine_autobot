require_dependency "projects_controller"

module RedmineAutobot
  module ProjectsControllerPatch
    def self.included(base)
      base.class_eval do

        def settings_with_redmine_autobot
          settings_without_redmine_autobot
          @autobot ||= @project.autobot || Autobot.new(:project => @project)
        end
        alias_method :settings_without_redmine_autobot, :settings
        alias_method :settings, :settings_with_redmine_autobot

      end
    end
  end
end
