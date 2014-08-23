require 'spec_helper'
require 'active_publisher'

describe ActivePublisher do
  describe "VERSION" do
    it { expect(subject.const_get('VERSION')).not_to be_empty }
  end
end
