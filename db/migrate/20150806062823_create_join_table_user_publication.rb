class CreateJoinTableUserPublication < ActiveRecord::Migration
  def change
    create_join_table :users, :publications
  end
end
