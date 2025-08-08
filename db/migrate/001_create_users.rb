class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :name, null: false, comment: 'User display name'
        t.string :username, null: false, comment: 'Unique username'
        t.integer :user_status, default: 0, null: false, comment: 'User account status: 0=active; 1=inactive'

        t.timestamps
      end

      add_index :users, :username, unique: true
      add_index :users, :user_status
    end
  end
end
