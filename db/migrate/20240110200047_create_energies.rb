class CreateEnergies < ActiveRecord::Migration[7.1]
  def change
    create_table :energies, id: false do |t|
      t.timestamptz :datetime, null: false, primary_key: true
      t.float :enphase
      t.float :from_sce
      t.float :to_sce

      t.timestamps
    end
  end
end
