require 'rails_helper'

RSpec.describe Users::CreateContract do
  let(:contract) { described_class.new }

  describe 'valid params' do
    it 'passes with valid user data' do
      params = { user: { name: 'John Doe', username: 'johndoe' } }
      result = contract.call(params)
      
      expect(result).to be_success
      expect(result.to_h).to eq(params)
    end
  end

  describe 'invalid params' do
    it 'fails when name is missing' do
      params = { user: { username: 'johndoe' } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:name]).to include('is missing')
    end

    it 'fails when username is missing' do
      params = { user: { name: 'John Doe' } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:username]).to include('is missing')
    end

    it 'fails when name is blank' do
      params = { user: { name: '' } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:name]).to include('must be filled')
    end

    it 'fails when name is too short' do
      params = { user: { name: 'A' } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:name]).to include('must be at least 2 characters long')
    end

    it 'fails when name is too long' do
      params = { user: { name: 'A' * 51 } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:name]).to include('must be less than 50 characters')
    end

    it 'fails when name is only numbers' do
      params = { user: { name: '12345' } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:name]).to include('cannot be only numbers')
    end

    it 'fails when name contains invalid characters' do
      params = { user: { name: 'John<script>' } }
      result = contract.call(params)
      
      expect(result).to be_failure
      expect(result.errors[:user][:name]).to include('contains invalid characters')
    end

    describe 'username validations' do
      it 'fails when username is too short' do
        params = { user: { name: 'John Doe', username: 'ab' } }
        result = contract.call(params)
        
        expect(result).to be_failure
        expect(result.errors[:user][:username]).to include('must be at least 3 characters long')
      end
      
      it 'fails when username is too long' do
        params = { user: { name: 'John Doe', username: 'a' * 21 } }
        result = contract.call(params)
        
        expect(result).to be_failure
        expect(result.errors[:user][:username]).to include('must be less than 20 characters')
      end
      
      it 'fails when username contains invalid characters' do
        params = { user: { name: 'John Doe', username: 'john-doe!' } }
        result = contract.call(params)
        
        expect(result).to be_failure
        expect(result.errors[:user][:username]).to include('only allows letters, numbers, and underscores')
      end
      
      it 'fails when username is only numbers and underscores' do
        params = { user: { name: 'John Doe', username: '123_456' } }
        result = contract.call(params)
        
        expect(result).to be_failure
        expect(result.errors[:user][:username]).to include('must contain at least one letter')
      end
      
      it 'fails when username already exists' do
        allow(User).to receive(:exists?).with(username: 'existing_user').and_return(true)
        params = { user: { name: 'John Doe', username: 'existing_user' } }
        result = contract.call(params)
        
        expect(result).to be_failure
        expect(result.errors[:user][:username]).to include('username has already been taken')
      end
    end
  end
end
