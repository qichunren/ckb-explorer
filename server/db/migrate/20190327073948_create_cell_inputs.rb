class CreateCellInputs < ActiveRecord::Migration[5.2]
  def change
    create_table :cell_inputs do |t|
      t.jsonb :previous_output
      t.belongs_to :ckb_transaction, index: true

      t.timestamps
    end
  end
end
