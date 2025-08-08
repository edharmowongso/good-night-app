require 'rails_helper'

RSpec.describe Follows::DestroyService do
  let(:follower) { double('User', name: 'Follower') }
  let(:followed) { double('User', name: 'Followed') }
  let(:service) { described_class.new(follower, followed) }

  describe '#call' do
    it 'unfollows user successfully' do
      allow(follower).to receive(:following?).with(followed).and_return(true)
      allow(follower).to receive(:unfollow).with(followed).and_return(true)
      
      result = service.call
      expect(result).to be_success
    end

    it 'validates user is following before unfollowing' do
      allow(follower).to receive(:following?).with(followed).and_return(false)
      
      expect { service.call }.to raise_error(BadRequestError)
    end
  end
end
