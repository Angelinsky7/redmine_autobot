require_dependency "project"

module RedmineAutobot
  module ProjectPatch
    def self.included(base)
      base.class_eval do

        has_one :autobot, :dependent => :destroy
        
        # def autobot?
        #   result = autobot
        #   if result.nil?
        #     logger.info "create from scratch..."
        #     result = Autobot.new(:project => self)
        #   end
        #   result
        # end

      end
    end
  end
end
