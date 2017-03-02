class WorkflowStepJob < ApplicationJob
  queue_as :default

  def perform(step)
    workflow = step.workflow
    step.run
    step.destroy
    workflow.resume
  end
end
