class WorkflowStep < ApplicationRecord
  has_and_belongs_to_many :dependencies,
                          class_name:              'WorkflowStep',
                          join_table:              'workflow_dependencies',
                          foreign_key:             'step_id',
                          association_foreign_key: 'dependency_id'
  has_and_belongs_to_many :successors,
                          class_name:              'WorkflowStep',
                          join_table:              'workflow_dependencies',
                          foreign_key:             'dependency_id',
                          association_foreign_key: 'step_id'

  attribute :arguments, :arguments

  validates :workflow_uuid,
            presence: true,
            format:   {with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/}
  validates :workflow_class_name,
            presence: true
  validate :class_and_step_name_valid

  def workflow_class
    workflow_class_name.constantize
  end

  def workflow
    workflow_class.new(id: workflow_uuid)
  end

  def workflow=(workflow)
    self.workflow_uuid       = workflow.id
    self.workflow_class_name = workflow.class.name
  end

  def noop?
    !step_name?
  end

  def run
    return if noop?

    workflow.run_step step_name, arguments
  end

  private

  def class_and_step_name_valid
    errors.add(:workflow_class_name, :invalid) if workflow_class_name.safe_constantize.nil?
    errors.add(:workflow_class_name, :invalid) unless workflow_class.ancestors.include?(Workflow)
    errors.add(:step_name, :invalid) if step_name && !workflow_class._steps.include?(step_name.to_sym)
  end
end
