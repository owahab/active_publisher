require 'spec_helper'

describe NotPublisher do
  it { expect(subject.class).to respond_to(:acts_as_publisher) }
  it { expect(subject.class).to respond_to(:acts_as_subscriber) }
  it { expect(subject).not_to respond_to(:publish) }
  it { expect(subject).not_to respond_to(:subscribers) }
  it { expect(subject).not_to respond_to(:subscribe) }
  it { expect(subject).not_to respond_to(:unsubscribe) }
  it { expect(subject).not_to respond_to(:notifications) }
end
