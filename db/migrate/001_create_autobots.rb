class CreateAutobots < ActiveRecord::Migration
  def self.up
    create_table :autobots, :force => true do |t|
      t.column :days_until_stale,   :integer, :null => false, :default => 60
      t.column :days_until_close,   :integer, :null => false, :default => 7
      t.column :only_labels,        :string
      t.column :exempt_labels,      :string
      t.column :exempt_milestones,  :string
      t.column :exempt_assignees,   :string
      t.column :stale_label,        :string,  :null => false
      t.column :mark_comment,       :string
      t.column :project_id,         :integer, :null => false
      t.column :created_on,         :datetime
      t.column :updated_on,         :datetime
    end

    add_index :autobots, [:project_id], :name => "autobot_project"
  end

  def self.down
    drop_table :autobots
  end
end
  