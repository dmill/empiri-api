class CreateThreads < ActiveRecord::Migration
  def change
    create_table :threads do |t|
      t.string :title
    end
  end
end
