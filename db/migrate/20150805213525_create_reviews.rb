class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :thread_id
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
