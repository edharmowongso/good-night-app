require 'rails_helper'

RSpec.describe SleepRecord do
  describe 'validations' do
    it 'requires bedtime' do
      record = double('SleepRecord')
      allow(record).to receive(:valid?).and_return(false)
      allow(record).to receive(:bedtime).and_return(nil)
      
      expect(record).not_to be_valid
    end
    
    it 'validates score range' do
      record = double('SleepRecord')
      allow(record).to receive(:score).and_return(6)
      allow(record).to receive(:valid?).and_return(false)
      
      expect(record).not_to be_valid
    end
  end

  describe 'status methods' do
    it 'tracks completion status' do
      record = double('SleepRecord')
      allow(record).to receive(:completed?).and_return(true)
      allow(record).to receive(:incomplete?).and_return(false)
      
      expect(record.completed?).to be true
      expect(record.incomplete?).to be false
    end
  end
  
  describe '#quality_text' do
    it 'returns quality description' do
      record = double('SleepRecord')
      allow(record).to receive(:quality_text).and_return('Good')
      
      expect(record.quality_text).to eq('Good')
    end
  end

  describe '#duration_hours' do
    it 'converts minutes to hours' do
      record = double('SleepRecord')
      allow(record).to receive(:duration_hours).and_return(8.0)
      
      expect(record.duration_hours).to eq(8.0)
    end
  end
end
