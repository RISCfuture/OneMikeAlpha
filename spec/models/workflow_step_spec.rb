require 'rails_helper'
require 'workflow'

RSpec.describe WorkflowStep, type: :model do
  around :each do |ex|
    Object.const_set :ExampleWorkflow, Class.new(Workflow) do
      step(:step1) {}
      step(:step2) {}
    end
    ex.run
    Object.send :remove_const, :ExampleWorkflow
  end

  describe '#workflow_class' do
    it "should return the class instance for the workflow" do
      step = FactoryBot.build(:workflow_step, workflow_class_name: 'ExampleWorkflow')
      expect(step.workflow_class).to eql(ExampleWorkflow)
    end
  end

  describe '#workflow' do
    it "should return a configured workflow instance" do
      step = FactoryBot.build(:workflow_step, workflow_class_name: 'ExampleWorkflow')
      expect(step.workflow).to be_kind_of(ExampleWorkflow)
      expect(step.workflow.id).to eql(step.workflow_uuid)
    end
  end

  describe '#workflow=' do
    it "should set workflow UUID and class name" do
      step          = FactoryBot.build(:workflow_step)
      uuid          = SecureRandom.uuid
      step.workflow = ExampleWorkflow.new(id: uuid)
      expect(step.workflow_uuid).to eql(uuid)
      expect(step.workflow_class_name).to eql('ExampleWorkflow')
    end
  end

  describe '#noop?' do
    it "should return true if step_name is nil and false otherwise" do
      expect(FactoryBot.build(:workflow_step, step_name: nil)).to be_noop
      expect(FactoryBot.build(:workflow_step, step_name: 'step1')).not_to be_noop
    end
  end

  describe '#run' do
    let(:workflow) { instance_double('ExampleWorkflow') }

    before(:each) { allow(ExampleWorkflow).to receive(:new).and_return(workflow) }

    it "should do nothing for a noop step" do
      step = FactoryBot.build(:workflow_step, workflow_class_name: 'ExampleWorkflow', step_name: nil)
      expect(workflow).not_to receive(:run_step)
      step.run
    end

    it "should call run_step on the workflow" do
      step = FactoryBot.build(:workflow_step, workflow_class_name: 'ExampleWorkflow', step_name: 'step1', arguments: ['foo', 1])
      expect(workflow).to receive(:run_step).once.with('step1', ['foo', 1])
      step.run
    end
  end
end
