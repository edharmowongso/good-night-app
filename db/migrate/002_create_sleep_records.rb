class CreateSleepRecords < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:sleep_records)
      create_table :sleep_records do |t|
        t.references :user, null: false, foreign_key: true, comment: 'User who owns this sleep record'
        t.datetime :bedtime, null: false, comment: 'When user went to bed'
        t.datetime :wake_time, comment: 'When user woke up (null if still sleeping)'
        t.integer :duration_minutes, comment: 'Calculated sleep duration in minutes'
        t.integer :score, comment: 'Sleep quality rating from 1-5 (1=terrible, 5=excellent)'
        t.text :notes, comment: 'Personal sleep notes and reflections'
        t.integer :status, default: 0, null: false, comment: 'Sleep record status: 0=incomplete, 1=completed, 2=cancelled'

        t.timestamps
      end

      add_index :sleep_records, :created_at
      add_index :sleep_records, :duration_minutes
      add_index :sleep_records, :score
      add_index :sleep_records, :status
    end
  end
end
