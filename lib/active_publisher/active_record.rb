module ActivePublisher
  module ActiveRecord
    def self.included(base)
      base.extend ClassMethods
      base.class_attribute :active_publisher_events
      base.class_attribute :active_publisher_messages
    end
    
    module ClassMethods
      def acts_as_subscriber
        require "active_publisher/models/subscriber"
        include ActivePublisher::Models::Subscriber
        #TODO on destroy, unsubscribe from all topics and publishers
      end

      def acts_as_publisher events = nil
        if events
          if events.is_a?(String) || events.is_a?(Symbol)
            events = [events.to_sym]
          end
          self.active_publisher_events = events
          # Due to the lack of ActiveRecord before_filter,
          # we will have to alias the original method in order to intercept
          if [:create, :update, :destroy].include? events
            include ActiveModel::Dirty
          else
            events.each do |event|
              define_method "#{event.to_s}_with_activepublisher" do |*args|
                if self.send("#{event.to_s}_without_activepublisher", *args)
                
                end
              end
              alias_method_chain event, 'activepublisher'
            end
          end
          #TODO on destroy, unsubscribe all subscribers
          # For actions that can be intercepted using ActiveRecord callbacks
          before_destroy :active_publisher_publish_destroying
          after_save :active_publisher_publish_updating 
          # We use after_save for creation to make sure all associations
          # have been persisted
          after_save :active_publisher_publish_creating
        end
        require "active_publisher/models/publisher"
        include ActivePublisher::Models::Publisher
      end
    end
  end
end
