require "redmine_autobot/core_ext"

module RedmineAutobot
  class Bot

    def self.preview
      STDERR.puts("All this issue would be marked as staled: ")
      self.enumerate_issues_to_mark_as_staled do |issue, autobot|
        STDERR.puts("issue found:  \##{issue.id} - '#{issue.updated_on}', tags: '#{issue.tags.join(', ')}' -> change tag to '#{autobot.stale_label}'")
      end

      STDERR.puts("Check for all staled issue to close:")

      self.enumerate_issues_to_close do |issue, autobot|
        STDERR.puts("issue found:  \##{issue.id} - '#{issue.updated_on}', tags: '#{issue.tags.join(', ')}' -> change closed")
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

            unless autobot.mark_comment.blank?
              issue.init_journal(user, autobot.mark_comment) 
            else
              issue.init_journal(user)
            end

            issue.tag_list.push(autobot.stale_label.to_s)
            issue.save
          end
        end
        
        STDERR.puts("Check for all staled issue to close")

        self.enumerate_issues_to_close do |issue, autobot|
          status_closed = IssueStatus.find(autobot.close_status.to_i)
          STDERR.puts "Closing issue \##{issue.id} (#{issue.subject}) with status: #{status_closed.name}"
          issue.init_journal(user)
          issue.status = status_closed
          issue.save
        end

      else  
        STDERR.puts("Cannot execute because not user was selected to execute the action. Please select a user in the config.")
      end

    end

    private

    def self.get_user(user_id_or_email)
      User.find_by_mail(user_id_or_email)
    end

    def self.get_tag_as_s(tags)
      tags.collect{|t| t.name}
    end

    def self.enumerate_issues_to_mark_as_staled(&block)     
      enumerate_issues_with_option(true, &block)
    end  


    def self.enumerate_issues_to_close(&block)
      enumerate_issues_with_option(false, &block)
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
            filter_issue = stale_mod ? !get_tag_as_s(issue.tags).include?(autobot.stale_label) : get_tag_as_s(issue.tags).include?(autobot.stale_label)
            filter_issue &= only_labels_collection.nil? || !(get_tag_as_s(issue.tags) & only_labels_collection).empty?
            filter_issue &= exempt_labels_collection.nil? || (get_tag_as_s(issue.tags) & exempt_labels_collection).empty?
            filter_issue &= versions_collection.nil? || !versions_collection.include?(issue.fixed_version_id)
            filter_issue &= assignees_collection.nil? || !assignees_collection.include?(issue.assigned_to_id)
            # STDERR.puts("filter_issue \##{issue.id} : #{filter_issue}");
            yield [issue, autobot] if filter_issue
          end



        end
      end 
    end

  end 
end