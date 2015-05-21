class CreateEmbedsTable < ActiveRecord::Migration
  def up
    create_table "embeds", :force => true do |t|
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "fulltext"
      t.integer  "width",  :default => 470
      t.integer  "height", :default => 353
    end
  end

  def down
    drop_table "embeds"
  end
end
