require_dependency "settings_helper"

module RedmineAutobot
  module SettingsHelperPatch
    def self.included(base)
      base.class_eval do

        def parent_issue_done_ratio_options_with_redmine_parent_percent
          options = [
            [:redmine_parent_percent_calc_done_on_total, 'calc_done_on_total'],
          ]      
          parent_issue_done_ratio_options_without_redmine_parent_percent + options.map {|label, value| [l(label), value.to_s]}
        end
        alias_method :parent_issue_done_ratio_options_without_redmine_parent_percent, :parent_issue_done_ratio_options
        alias_method :parent_issue_done_ratio_options, :parent_issue_done_ratio_options_with_redmine_parent_percent
  
      end
    end
  end
end