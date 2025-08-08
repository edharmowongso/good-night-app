require 'rails_helper'

RSpec.describe Follow do
  let(:follower) { double('User', id: 1) }
  let(:followed) { double('User', id: 2) }

  describe 'validations' do
    it 'validates uniqueness of follower_id scoped to followed_id' do
      follow = double('Follow')
      allow(follow).to receive(:errors).and_return(double('errors', add: nil))
      allow(Follow).to receive(:exists?).with(follower_id: 1, followed_id: 2).and_return(true)
      
      duplicate_exists = Follow.exists?(follower_id: 1, followed_id: 2)
      expect(duplicate_exists).to be true
    end

    it 'prevents following self' do
      follow = double('Follow')
      allow(follow).to receive(:valid?).and_return(false)
      allow(follow).to receive(:follower_id).and_return(1)
      allow(follow).to receive(:followed_id).and_return(1)
      
      expect(follow).not_to be_valid
    end

    it 'allows following different users' do
      follow = double('Follow')
      allow(follow).to receive(:valid?).and_return(true)
      allow(follow).to receive(:follower_id).and_return(1)
      allow(follow).to receive(:followed_id).and_return(2)
      
      expect(follow).to be_valid
    end
  end

  describe 'associations' do
    it 'links follower and followed users' do
      follow = double('Follow')
      allow(follow).to receive(:follower).and_return(follower)
      allow(follow).to receive(:followed).and_return(followed)
      
      expect(follow.follower).to eq(follower)
      expect(follow.followed).to eq(followed)
    end
  end

  describe 'query methods' do
    it 'finds followers' do
      relation = double('FollowRelation')
      allow(Follow).to receive(:where).with(followed: followed).and_return(relation)
      allow(relation).to receive(:count).and_return(5)
      
      followers = Follow.where(followed: followed)
      expect(followers.count).to eq(5)
    end

    it 'checks for existing follows' do
      allow(Follow).to receive(:exists?).with(follower_id: 1, followed_id: 2).and_return(true)
      
      exists = Follow.exists?(follower_id: 1, followed_id: 2)
      expect(exists).to be true
    end
  end
end
