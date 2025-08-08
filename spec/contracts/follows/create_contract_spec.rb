require 'rails_helper'

RSpec.describe Follows::CreateContract do
  let(:current_user) { instance_double(User, id: 1) }
  let(:other_user) { instance_double(User, id: 2) }
  let(:contract) { described_class.new(current_user: current_user) }
  
  before do
    allow(User).to receive(:exists?).and_return(false)
    allow(User).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
  end

  describe 'valid params' do
    it 'passes with valid followed_id' do
      followed_id = 2

      allow(User).to receive(:exists?).with(id: followed_id).and_return(true)
      allow(User).to receive(:find).with(followed_id).and_return(other_user)
      allow(current_user).to receive(:following?).with(other_user).and_return(false)
      
      params = { followed_id: followed_id }
      result = contract.call(params)
      
      expect(result).to be_success
      expect(result.to_h).to eq(params)
    end
  end

  describe 'invalid params' do
    it 'fails when followed_id is missing' do
      params = {}
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:followed_id]).to include('is missing')
    end

    it 'fails when followed_id is negative' do
      params = { followed_id: -1 }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:followed_id]).to include('must be a positive integer')
    end

    it 'fails when user does not exist' do
      params = { followed_id: 99999 }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:followed_id]).to include('User to follow not found')
    end

    xit 'fails when trying to follow self' do
      followed_id = 1
      allow(User).to receive(:exists?).with(id: followed_id).and_return(true)
      
      params = { followed_id: followed_id }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:followed_id]).to include('Cannot follow yourself')
    end

    it 'fails when already following user' do
      followed_id = 2
      allow(User).to receive(:exists?).with(id: followed_id).and_return(true)
      allow(User).to receive(:find).with(followed_id).and_return(other_user)
      allow(current_user).to receive(:following?).with(other_user).and_return(true)
      
      params = { followed_id: followed_id }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:followed_id]).to include('You are already following this user')
    end
  end
end
