class DropTableUserinfos < ActiveRecord::Migration
  def change
    drop_table :userinfos
  end
end
