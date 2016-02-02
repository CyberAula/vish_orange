class AddMoocColumnsToUser < ActiveRecord::Migration
  def self.up
     add_column :users, :surname, :string
     add_column :users, :center_code, :string
     add_column :users, :mooc, :boolean, :default => false
  end

  def self.down
    remove_column :users, :surname
    remove_column :users, :center_code
    remove_column :users, :mooc
  end
end
