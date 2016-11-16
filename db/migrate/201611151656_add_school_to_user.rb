class AddSchoolToUser < ActiveRecord::Migration
  def up
  	change_table "users" do |t|
      t.string "school"
    end
  end

  def down
  	change_table "users" do |t|
      t.remove "school"
    end
  end
end
