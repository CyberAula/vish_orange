class LinkImageLength < ActiveRecord::Migration
  def up
    change_column :links, :image, :string, :limit => 800
   end

   def down
     change_column :links, :image, :string, :limit => 255
   end
end
