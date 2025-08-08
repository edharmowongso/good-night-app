class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:follows)
      create_table :follows do |t|
        t.references :follower, null: false, foreign_key: { to_table: :users }, comment: 'User who is following'
        t.references :followed, null: false, foreign_key: { to_table: :users }, comment: 'User being followed'
        t.timestamps
      end

      add_index :follows, [:follower_id, :followed_id], unique: true
    end
  end
end
