require_dependency "project"

module RedmineAutobot
  module ProjectPatch
    def self.included(base)
      base.class_eval do

        has_one :autobot, :dependent => :destroy
        
      end
    end
  end
end
