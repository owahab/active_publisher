module ActivePublisher
  class UnpresistedObject < Exception; end
  class InvalidPublisher < Exception; end
  class InvalidSubscriber < Exception; end
  class SubscriberNotAcceptingNotifications < Exception; end
end