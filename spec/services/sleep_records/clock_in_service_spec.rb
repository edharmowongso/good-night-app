require 'rails_helper'

RSpec.describe SleepRecords::ClockInService do
  let(:user) { double('User') }
  let(:service) { described_class.new(user) }

  describe '#call' do
    it 'creates new sleep record' do
      sleep_records = double('sleep_records')
      allow(user).to receive(:sleep_records).and_return(sleep_records)
      allow(sleep_records).to receive_message_chain(:incomplete, :order, :last).and_return(nil)
      allow(sleep_records).to receive(:create!).and_return(double('SleepRecord'))
      allow(sleep_records).to receive_message_chain(:includes, :order).and_return([])
      
      result = service.call
      expect(result).to be_success
    end

    it 'completes previous incomplete record' do
      sleep_records = double('sleep_records')
      previous_record = double('SleepRecord', bedtime: 2.hours.ago)
      allow(user).to receive(:sleep_records).and_return(sleep_records)
      allow(sleep_records).to receive_message_chain(:incomplete, :order, :last).and_return(previous_record)
      allow(previous_record).to receive(:update!)
      allow(sleep_records).to receive(:create!).and_return(double('SleepRecord'))
      allow(sleep_records).to receive_message_chain(:includes, :order).and_return([])
      
      expect(previous_record).to receive(:update!)
      service.call
    end
  end
end
