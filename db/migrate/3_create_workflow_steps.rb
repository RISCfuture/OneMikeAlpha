class CreateWorkflowSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :workflow_steps do |t|
      t.string :workflow_uuid, null: false, limit: 36
      t.string :workflow_class_name, null: false
      t.string :step_name # null = noop
      t.text :arguments
      t.boolean :processing, null: false, default: false
    end

    add_index :workflow_steps, :workflow_uuid
  end
end
