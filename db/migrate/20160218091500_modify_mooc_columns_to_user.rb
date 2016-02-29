class ModifyMoocColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :madridorgid, :string
    #the rest of the lines remove the last two migration, because we did the course functionality the correct way in vish
    remove_column :users, :center_code
    remove_column :users, :mooc
    remove_column :users, :mailmoocsent
  end

  def self.down    
    remove_column :users, :madridorgid
    add_column :users, :center_code, :string
    add_column :users, :mooc, :boolean, :default => false
    add_column :users, :mailmoocsent, :boolean, :default => false
  end
end
