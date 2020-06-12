require "redmine_autobot/core_ext"

module RedmineAutobot
  class Bot

    def self.preview
      self.enumerate_issues_to_mark_as_staled do |issue, autobot|
        STDERR.puts("issue found:  \##{issue.id} - '#{issue.updated_on}', tags: '#{issue.tags.join(', ')}' :: '#{issue.tag_list}' -> change tag to '#{autobot.stale_label}'")
      end
      
    end

    def self.execute
      config_user = Setting.plugin_redmine_autobot['autobot_user']
      user = get_user(config_user);

      STDERR.puts("User executing:  #{user.name}")
      STDERR.puts("Check for all issue to mark as stale")

      unless config_user.nil?
        self.enumerate_issues_to_mark_as_staled do |issue, autobot|
          unless autobot.stale_label.blank? 
            STDERR.puts "Marking issue \##{issue.id} (#{issue.subject}) as staled"
            journal = issue.init_journal(user, autobot.mark_comment) unless autobot.mark_comment.blank?
            issue.tag_list.push(autobot.stale_label.to_s)
            issue.save
          end
        end
        
        STDERR.puts("Check for all staled issue to close")

      else  
        STDERR.puts("Cannot execute because not user was selected to execute the action. Please select a user in the config.")
      end

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

#   STDERR.puts("Preview issue \##{issue.id} (#{issue.subject}), status '#{issue.status.name}', with text '#{config.note.split('\\n').first.strip}...', resolved #{when_resolved}")

    def self.enumerate_issues_to_mark_as_staled      
      enumerate_issues_with_option(true)
      # config_subproject = Setting.plugin_redmine_autobot['autobot_subprojects']
      # projects = Project.active.has_module('redmine_autobot')

      # projects.each do |project|
      #   unless project.autobot.nil?
      #     autobot = project.autobot;
      #     statuses_to_check = IssueStatus.where("id IN (#{autobot.statuses_as_array.join(', ')})");
      #     trackers_to_check = Tracker.where("id IN (#{autobot.trackers_as_array.join(', ')})");
      #     offset_seconds_to_stale = 86400 * autobot.days_until_stale

      #     issues = Issue.visible
      #         .includes(:custom_values)
      #         .where(project.project_condition(config_subproject))
      #         .where("status_id IN (#{statuses_to_check.collect{|t| t.id}.join(', ')})")
      #         .where("tracker_id IN (#{trackers_to_check.collect{|t| t.id}.join(', ')})")
      #         .where("issues.updated_on < ?", Time.zone.now - offset_seconds_to_stale)
         
      #     only_labels_collection = autobot.only_labels.collection_split_reject_strip unless autobot.only_labels.blank?
      #     exempt_labels_collection = autobot.exempt_labels.collection_split_reject_strip unless autobot.exempt_labels.blank?
      #     versions_collection = Version.where(:project => project).where("name IN (#{autobot.exempt_milestones.collection_split_reject_collect_join})").collect{|t| t.id} unless autobot.exempt_milestones.blank?
      #     assignees_collection = User.where("login IN (#{autobot.exempt_assignees.collection_split_reject_collect_join})").collect{|t| t.id} unless autobot.exempt_assignees.blank?

      #     # STDERR.puts("only_labels_collection: #{only_labels_collection.nil?} - #{only_labels_collection}")
      #     # STDERR.puts("exempt_labels_collection: #{exempt_labels_collection.nil?} - #{exempt_labels_collection}")
      #     # STDERR.puts("versions_collection: #{versions_collection.nil?} - #{versions_collection}")

      #     issues.each do |issue|
      #       filter_issue = !issue.tags.include?(autobot.stale_label)
      #       filter_issue &= only_labels_collection.nil? || !(issue.tags.collect{|t| t.name} & only_labels_collection).empty?
      #       filter_issue &= exempt_labels_collection.nil? || (issue.tags.collect{|t| t.name} & exempt_labels_collection).empty?
      #       filter_issue &= versions_collection.nil? || !versions_collection.include?(issue.fixed_version_id)
      #       filter_issue &= assignees_collection.nil? || !assignees_collection.include?(issue.assigned_to_id)
      #       # STDERR.puts("filter_issue #{filter_issue}");
      #       yield [issue, autobot] if filter_issue
      #     end

      #   end
      # end 
    end  


    def self.enumerate_issues_to_close
      enumerate_issues_with_option(false)
    end

    def self.enumerate_issues_with_option(stale_mod)
      config_subproject = Setting.plugin_redmine_autobot['autobot_subprojects']
      projects = Project.active.has_module('redmine_autobot')
      
      projects.each do |project|
        unless project.autobot.nil?
          autobot = project.autobot;
          statuses_to_check = IssueStatus.where("id IN (#{autobot.statuses_as_array.join(', ')})");
          trackers_to_check = Tracker.where("id IN (#{autobot.trackers_as_array.join(', ')})");
          offset_seconds_to_check = 86400 * (stale_mod ? autobot.days_until_stale : autobot.days_until_close)

          issues = Issue.visible
              .includes(:custom_values)
              .where(project.project_condition(config_subproject))
              .where("status_id IN (#{statuses_to_check.collect{|t| t.id}.join(', ')})")
              .where("tracker_id IN (#{trackers_to_check.collect{|t| t.id}.join(', ')})")
              .where("issues.updated_on < ?", Time.zone.now - offset_seconds_to_check)
         
          only_labels_collection = autobot.only_labels.collection_split_reject_strip unless autobot.only_labels.blank?
          exempt_labels_collection = autobot.exempt_labels.collection_split_reject_strip unless autobot.exempt_labels.blank?
          versions_collection = Version.where(:project => project).where("name IN (#{autobot.exempt_milestones.collection_split_reject_collect_join})").collect{|t| t.id} unless autobot.exempt_milestones.blank?
          assignees_collection = User.where("login IN (#{autobot.exempt_assignees.collection_split_reject_collect_join})").collect{|t| t.id} unless autobot.exempt_assignees.blank?

          # STDERR.puts("only_labels_collection: #{only_labels_collection.nil?} - #{only_labels_collection}")
          # STDERR.puts("exempt_labels_collection: #{exempt_labels_collection.nil?} - #{exempt_labels_collection}")
          # STDERR.puts("versions_collection: #{versions_collection.nil?} - #{versions_collection}")

          issues.each do |issue|
            filter_issue = stale_mod ? !issue.tags.include?(autobot.stale_label) : issue.tags.include?(autobot.stale_label)
            filter_issue &= only_labels_collection.nil? || !(issue.tags.collect{|t| t.name} & only_labels_collection).empty?
            filter_issue &= exempt_labels_collection.nil? || (issue.tags.collect{|t| t.name} & exempt_labels_collection).empty?
            filter_issue &= versions_collection.nil? || !versions_collection.include?(issue.fixed_version_id)
            filter_issue &= assignees_collection.nil? || !assignees_collection.include?(issue.assigned_to_id)
            # STDERR.puts("filter_issue #{filter_issue}");
            yield [issue, autobot] if filter_issue
          end

        end
      end 
    end

  end 
end