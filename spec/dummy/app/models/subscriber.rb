class Subscriber < ActiveRecord::Base
  acts_as_subscriber
  
  def deliver_notification id
  end
end
