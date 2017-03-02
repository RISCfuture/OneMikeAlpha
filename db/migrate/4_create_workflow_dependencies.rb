class CreateWorkflowDependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :workflow_dependencies, id: false do |t|
      t.belongs_to :step, foreign_key: {to_table: :workflow_steps, on_delete: :restrict}, null: false
      t.belongs_to :dependency, foreign_key: {to_table: :workflow_steps, on_delete: :cascade}, null: false
    end
  end
end
