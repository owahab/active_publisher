require 'spec_helper'

describe Subscriber do
  it { expect(subject.class).to respond_to(:acts_as_publisher) }
  it { expect(subject.class).to respond_to(:acts_as_subscriber) }
  it { expect(subject).not_to respond_to(:publish) }
  it { expect(subject).to respond_to(:subscribe) }
  it { expect(subject).to respond_to(:unsubscribe) }
  it { expect(subject).to respond_to(:subscriptions) }
  it { expect(subject).to respond_to(:notifications) }
    
  describe ".subscriptions" do
    it { expect(subject.subscriptions(:any)).to be_kind_of Array }
  end
  
  describe ".subscribe" do
    let(:subject) { FactoryGirl.create(:subscriber) }
    let(:publisher) { FactoryGirl.create(:publisher) }
    it { expect { subject.subscribe(publisher, :any) }.not_to raise_exception }
    it { expect(subject.subscribe(publisher, :any)).to eq true }
    
    describe "to publisher" do
      describe "object" do
        let!(:subscription) { subject.subscribe(publisher, :any) }
    
        it { expect(subject.subscriptions(:any).count).to eq 1 }
        it { expect(subject.subscriptions(:any)).to include publisher.active_publisher_key(:any) }
        it { expect(publisher.subscribers(:any).count).to eq 1 }
        it { expect(publisher.subscribers(:any)).to include subject.active_publisher_key(:any) }
        
        describe ".notifications" do
          let!(:notify) { publisher.publish([:any], { foo: :bar }) }
          
          it { expect(subject.notifications).to be_kind_of ActivePublisher::NotificationProxy }
          it { expect(subject.notifications.count).to eq 1 }
        end
      end
    end
    describe "to topic" do
      let!(:subscription) { subject.subscribe 'test_topic', '' }

      it { expect(subject.subscriptions('').count).to eq 1 }
      it { expect(subject.subscriptions('')).to include ActivePublisher.key(['topics', 'test_topic']) }
    
      describe ".notifications" do
        let!(:notify) { ActivePublisher.publish_to_topic("test_topic", { foo: :bar })}
      
        it { expect(subject.notifications).to be_kind_of ActivePublisher::NotificationProxy }
        it { expect(subject.notifications.count).to eq 1 }
      end
    end
  end

  describe ".unsubscribe" do
    let(:publisher) { FactoryGirl.create(:publisher) }
    describe "with no subscriptions" do
      it { expect { subject.unsubscribe(publisher, :any) }.not_to raise_exception }
      it { expect(subject.unsubscribe(publisher, :any)).to eq false }
    end
    describe "with valid subscriptions" do
      let!(:subscription) { subject.subscribe publisher, :any }
      it { expect { subject.unsubscribe(publisher, :any) }.not_to raise_exception }
      it { expect(subject.unsubscribe(publisher, :any)).to eq true }
    end
    
    describe "from publisher" do
      let!(:unsubscribe) { subject.unsubscribe publisher, :any }
      
      it { expect(subject.subscriptions(:any).count).to eq 0 }
      it { expect(subject.subscriptions(:any)).not_to include publisher.active_publisher_key(:any) }
    end

    describe "from topic" do
      let!(:subscription) { subject.subscribe 'test_topic', :any }
      let!(:unsubscribe) { subject.unsubscribe 'test_topic', :any }

      it { expect(subject.subscriptions(:any).count).to eq 0 }
      it { expect(subject.subscriptions(:any)).not_to include ActivePublisher.key(['topics', 'test_topic']) }
    end
  end
  
  describe ".notifications" do
    it { expect(subject.notifications).to be_kind_of ActivePublisher::NotificationProxy }
  end
end
