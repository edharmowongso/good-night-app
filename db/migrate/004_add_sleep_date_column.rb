class AddSleepDateColumn < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:sleep_records, :sleep_date)
      add_column :sleep_records, :sleep_date, :date, null: true, 
               comment: 'Date of the sleep session (for efficient date filtering)'
    end

    remove_index :sleep_records, :created_at
    remove_index :sleep_records, :score

    add_index :sleep_records, [:user_id, :sleep_date], name: 'idx_sleep_records_user_date'
    add_index :sleep_records, [:user_id, :status], name: 'idx_sleep_records_user_status'
  end
end
