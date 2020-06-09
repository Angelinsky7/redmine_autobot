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

end
