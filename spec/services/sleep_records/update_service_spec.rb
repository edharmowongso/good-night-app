require 'rails_helper'

RSpec.describe SleepRecords::UpdateService do
  let(:sleep_record) { double('SleepRecord') }
  let(:params) { { score: 4 } }
  let(:service) { described_class.new(sleep_record, params) }

  describe '#call' do
    it 'updates sleep record attributes' do
      allow(sleep_record).to receive(:update!).and_return(true)
      allow(sleep_record).to receive(:reload).and_return(sleep_record)
      
      expect(sleep_record).to receive(:update!).with({ score: 4 })
      result = service.call
      expect(result).to be_success
    end

    it 'cancels sleep record' do
      service = described_class.new(sleep_record, { status: 'cancelled' })
      allow(sleep_record).to receive(:update!)
      allow(sleep_record).to receive(:reload).and_return(sleep_record)
      
      expect(sleep_record).to receive(:update!).with(
        status: :cancelled,
        wake_time: nil,
        duration_minutes: nil
      )
      service.call
    end

    it 'completes sleep record' do
      service = described_class.new(sleep_record, { status: 'completed' })
      allow(sleep_record).to receive(:incomplete?).and_return(true)
      allow(sleep_record).to receive(:bedtime).and_return(8.hours.ago)
      allow(sleep_record).to receive(:update!)
      allow(sleep_record).to receive(:reload).and_return(sleep_record)
      
      expect(sleep_record).to receive(:update!).with(hash_including(status: :completed))
      service.call
    end
  end
end
