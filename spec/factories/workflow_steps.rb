FactoryBot.define do
  factory :workflow_step do
    workflow_uuid { SecureRandom.uuid }
    workflow_class_name { 'ExampleWorkflow' }
    step_name { %w[step1 step2].sample }
  end
end
