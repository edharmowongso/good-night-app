require 'rails_helper'

RSpec.describe Follows::CreateService do
  let(:follower) { double('User', name: 'Follower') }
  let(:followed) { double('User', name: 'Followed') }
  let(:service) { described_class.new(follower, followed) }

  describe '#call' do
    it 'creates follow successfully' do
      follow = double('Follow', persisted?: true)
      allow(follower).to receive(:==).and_return(false)
      allow(follower).to receive(:following?).and_return(false)
      allow(follower).to receive(:follow).and_return(follow)
      
      result = service.call
      expect(result).to be_success
    end

    it 'validates against self-following' do
      allow(follower).to receive(:==).with(followed).and_return(true)
      
      expect { service.call }.to raise_error(BadRequestError)
    end

    it 'validates against already following' do
      allow(follower).to receive(:==).and_return(false)
      allow(follower).to receive(:following?).and_return(true)
      
      expect { service.call }.to raise_error(BadRequestError)
    end
  end
end
