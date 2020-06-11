module RedmineAutobot
  class Bot

    def self.preview
      self.enumerate_issues_to_mark_as_staled do |issue, autobot|
        STDERR.puts("issue found:  \##{issue.id} - '#{issue.updated_on}', tags: '#{issue.tags.join(', ')}' -> change tag to '#{autobot.stale_label}'")
      end
      
    end

    def self.execute
    end

    private

    # def self.stales_issues(project, config_subproject)
    #   conditions = []
    #   conditions << 
    #   conditions << "(tracker_id IN (#{project.trackers.collect {|tracker| tracker.id}.join(', ')}))"
    #   return conditions.join(' AND ')
    # end

    def self.get_user(user_id_or_email)
      User.find_by_mail(user_id_or_email)
    end

#     def self.when_issue_resolved issue, status_resolved
#       issue.journals.reverse_each do |j|
#         status_change = j.new_value_for('status_id')
#         return j.created_on if status_change && status_change.to_i == status_resolved.id
#       end
#       nil
#     end
  
#   def self.enumerate_issues config
#     status_resolved = IssueStatus.find_by_name('Resolved')
#     if config.projects == ['*']
#       projects = Project.all
#     else
#       projects = Project.where()
#     end
#     projects.each do |project|
#       project.issues.where(:status_id => status_resolved).each do |issue|
#         when_resolved = when_issue_resolved(issue, status_resolved)
#         yield [issue, when_resolved] if when_resolved && when_resolved < config.interval_time
#       end
#     end
#   end

    def self.enumerate_issues_to_mark_as_staled
      config_user = Setting.plugin_redmine_autobot['autobot_user']
      config_subproject = Setting.plugin_redmine_autobot['subprojects_issues']

    #   STDERR.puts("Preview issue \##{issue.id} (#{issue.subject}), status '#{issue.status.name}', with text '#{config.note.split('\\n').first.strip}...', resolved #{when_resolved}")

      unless config_user.nil?
        user = get_user(config_user);
        STDERR.puts("User executing:  #{user.name}")

        projects = Project.active.has_module('redmine_autobot')
        projects.each do |project|
          unless project.autobot.nil?
            autobot = project.autobot;
            statuses_to_check = IssueStatus.where("id IN (#{autobot.statuses_as_array.join(', ')})");
            trackers_to_check = Tracker.where("id IN (#{autobot.trackers_as_array.join(', ')})");
            offset_seconds_to_stale = 86400 * autobot.days_until_stale

            issues = Issue.visible
                .includes(:custom_values)
                .where(project.project_condition(config_subproject))
                .where("status_id IN (#{statuses_to_check.collect{|t| t.id}.join(', ')})")
                .where("tracker_id IN (#{trackers_to_check.collect{|t| t.id}.join(', ')})")
                .where("issues.updated_on < ?", Time.zone.now - offset_seconds_to_stale)
              
            issues.each do |issue|
              yield [issue, autobot]
            end

          end 
        end
      else  
        STDERR.puts("Cannot execute because not user was selected to execute the action. Please select a user in the config.")
      end  
    end

    def self.enumerate_issues_to_close
      #TODO(demarco): When implementing this, please find a way to reuse code from above...
    end

  end 
end