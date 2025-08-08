require 'rails_helper'

RSpec.describe User do
  let(:user) { User.new }
  let(:other_user) { double('User', id: 2) }

  describe '#follow' do
    it 'creates a follow relationship' do
      mock_follows = double('active_follows')
      allow(user).to receive(:active_follows).and_return(mock_follows)
      expect(mock_follows).to receive(:find_or_create_by).with(followed: other_user)
      
      user.follow(other_user)
    end

    it 'returns false when trying to follow self' do
      expect(user.follow(user)).to be_falsey
    end
  end

  describe '#unfollow' do
    it 'removes the follow relationship' do
      mock_follows = double('active_follows')
      mock_follow = double('follow')
      allow(user).to receive(:active_follows).and_return(mock_follows)
      expect(mock_follows).to receive(:find_by).with(followed: other_user).and_return(mock_follow)
      expect(mock_follow).to receive(:destroy)
      
      user.unfollow(other_user)
    end
  end

  describe '#following?' do
    it 'returns true when following' do
      mock_following = double('following')
      allow(user).to receive(:following).and_return(mock_following)
      expect(mock_following).to receive(:include?).with(other_user).and_return(true)
      
      expect(user.following?(other_user)).to be true
    end
  end
end
