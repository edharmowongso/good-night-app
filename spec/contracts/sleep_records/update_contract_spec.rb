require 'rails_helper'

RSpec.describe SleepRecords::UpdateContract do
  let(:contract) { described_class.new }

  describe 'score validation' do
    it 'passes with valid score' do
      result = contract.call(score: 3)
      expect(result).to be_success
    end

    it 'passes with nil score' do
      result = contract.call(score: nil)
      expect(result).to be_success
    end

    it 'fails with score below 1' do
      result = contract.call(score: 0)
      expect(result).to be_failure
      expect(result.errors[:score]).to include('must be between 1 and 5')
    end

    it 'fails with score above 5' do
      result = contract.call(score: 6)
      expect(result).to be_failure
      expect(result.errors[:score]).to include('must be between 1 and 5')
    end
  end

  describe 'notes validation' do
    it 'passes with valid notes' do
      result = contract.call(notes: 'Great sleep!')
      expect(result).to be_success
    end

    it 'passes with nil notes' do
      result = contract.call(notes: nil)
      expect(result).to be_success
    end

    it 'fails with notes too long' do
      long_notes = 'a' * 1001
      result = contract.call(notes: long_notes)
      expect(result).to be_failure
      expect(result.errors[:notes]).to include('cannot be longer than 1000 characters')
    end
  end

  describe 'status validation' do
    it 'passes with valid status' do
      result = contract.call(status: 'completed')
      expect(result).to be_success
    end

    it 'passes with incomplete status' do
      result = contract.call(status: 'incomplete')
      expect(result).to be_success
    end

    it 'passes with cancelled status' do
      result = contract.call(status: 'cancelled')
      expect(result).to be_success
    end

    it 'fails with invalid status' do
      result = contract.call(status: 'invalid_status')
      expect(result).to be_failure
      expect(result.errors[:status]).to include('must be incomplete, completed, or cancelled')
    end
  end

  describe 'wake_time validation' do
    it 'passes with valid wake_time' do
      result = contract.call(wake_time: '2023-08-08T08:00:00Z')
      expect(result).to be_success
    end

    it 'passes with nil wake_time' do
      result = contract.call(wake_time: nil)
      expect(result).to be_success
    end

    it 'fails with invalid datetime format' do
      result = contract.call(wake_time: 'invalid-date')
      expect(result).to be_failure
      expect(result.errors[:wake_time]).to include('invalid datetime format')
    end

    it 'fails with future wake_time' do
      future_time = (Time.current + 2.hours).iso8601
      result = contract.call(wake_time: future_time)
      expect(result).to be_failure
      expect(result.errors[:wake_time]).to include('cannot be more than 1 hour in the future')
    end
  end

  describe 'combined validation' do
    it 'passes with valid combined params' do
      result = contract.call(
        score: 4,
        notes: 'Good sleep',
        status: 'completed',
        wake_time: '2023-08-08T08:00:00Z'
      )
      expect(result).to be_success
    end

    it 'fails with multiple invalid params' do
      result = contract.call(
        score: 10,
        notes: 'a' * 1001,
        status: 'invalid'
      )
      expect(result).to be_failure
      expect(result.errors[:score]).to include('must be between 1 and 5')
      expect(result.errors[:notes]).to include('cannot be longer than 1000 characters')
      expect(result.errors[:status]).to include('must be incomplete, completed, or cancelled')
    end
  end
end
