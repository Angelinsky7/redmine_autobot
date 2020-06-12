class AddCloseStatus < ActiveRecord::Migration
    def self.up
      add_column :autobots, :close_status, :integer, :null => false, :default => 5
    end
  
    def self.down
      remove_columns :autobots, :close_status
    end
  end
    