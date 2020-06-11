require 'json'

class Autobot < ActiveRecord::Base
    include Redmine::SafeAttributes
    belongs_to :project
        
    validates_presence_of :days_until_stale
    validates_presence_of :days_until_close
    validates_presence_of :stale_label
    attr_protected :id

    safe_attributes :days_until_stale, :days_until_close, :only_labels, :exempt_labels, :exempt_milestones, :exempt_assignees, :statuses, :trackers ,:stale_label, :mark_comment

    def statuses_as_array
      JSON.parse(statuses || "[]").collect{|t| t.to_i} 
    end

    def trackers_as_array
      JSON.parse(trackers || "[]").collect{|t| t.to_i} 
    end

end
  