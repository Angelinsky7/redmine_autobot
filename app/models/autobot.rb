class Autobot < ActiveRecord::Base
    include Redmine::SafeAttributes
    belongs_to :project
    
    validates_presence_of :days_until_stale
    validates_presence_of :days_until_close
    validates_presence_of :stale_label
    attr_protected :id

    safe_attributes :days_until_stale, :days_until_close, :only_labels, :exempt_labels, :exempt_milestones, :exempt_assignees, :stale_label, :mark_comment

end
  