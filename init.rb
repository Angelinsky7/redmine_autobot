Project.send(:include, RedmineAutobot::ProjectPatch)
ProjectsHelper.send(:include, RedmineAutobot::ProjectsHelperPatch)
ProjectsController.send(:include, RedmineAutobot::ProjectsControllerPatch)

Redmine::Plugin.register :redmine_autobot do
  name 'Redmine Autobot'
  author 'Angelinsky7'
  description 'A bot to stale and close issue after some inactivity time'
  version '0.0.1'
  url 'https://github.com/Angelinsky7/redmine_autobot.git'
  author_url 'https://github.com/Angelinsky7/redmine_autobot.git'

  project_module :redmine_autobot do
    permission :redmine_autobot_manage, :autobot => :edit
  end

  settings :default => {
    'redmine_subprojects_issues' => false,
    'redmine_autobot_user' => '',
  },
  :partial => 'settings/autobot_settings'

end

Rails.configuration.to_prepare do
  Redmine::Plugin.find(:redmine_autobot).requires_redmine_plugin :redmine_tags, :version_or_higher => '3.2.1'
end