class AddSentMailColumnToUser < ActiveRecord::Migration
  def self.up
     add_column :users, :mailmoocsent, :boolean, :default => false
  end

  def self.down
    remove_column :users, :mailmoocsent
  end
end
