class AddStatusesAndTrackers < ActiveRecord::Migration
  def self.up
    add_column :autobots, :statuses, :string
    add_column :autobots, :trackers, :string
  end

  def self.down
    remove_columns :autobots, :statuses
    remove_columns :autobots, :trackers
  end
end
  