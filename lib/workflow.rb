require 'active_job/arguments'
require 'rgl/adjacency'

class Workflow
  attr_reader :id
  attr_reader :arguments
  class_attribute :_steps
  self._steps = Hash.new

  def initialize(arguments: nil, id: nil)
    @id        = id || self.class.uuid
    @arguments = arguments
  end

  def perform(*_args)
    raise NotImplementedError, "Must be implemented by subclasses"
  end

  def self.on_error(&block)
    @on_error_block = block
  end

  def self.perform_later(*args)
    instance = new(arguments: args)
    instance.build!
    instance.resume
    return instance
  end

  def self.perform_inline(*args)
    new(arguments: args).perform_inline
  end

  # @private
  def perform_inline
    build!
    yield self if block_given?
    until workflow_steps.empty?
      steps = workflow_steps.includes(:dependencies).where(processing: false).select { |s| s.dependencies.empty? }
      WorkflowStep.where(id: steps.map(&:id)).update_all processing: true
      WorkflowStep.where(id: steps.map(&:id)).each do |step|
        step.run
        step.destroy
      end
    end
  end

  # @private
  def resume
    steps = workflow_steps.includes(:dependencies).where(processing: false).select { |s| s.dependencies.empty? }
    WorkflowStep.where(id: steps.map(&:id)).update_all processing: true
    steps.each { |step| WorkflowStepJob.perform_later step }
  end

  def build!
    raise 'arguments not set' unless arguments

    visitor = StepBuilderVisitor.new
    g       = SequentialBuilder.new(self, visitor)
    g.build! { perform(*arguments) }
    g.connect!
  end

  # @private
  def visualize
    require 'rgl/dot'
    class << graph
      def vertex_label(v)
        "#{v.step_name || 'noop'} #{v.id}"
      end
    end
    graph.write_to_graphic_file
  end

  def run_step(step, arguments)
    self.class._steps[step.to_sym].call(*arguments)
  rescue StandardError => e
    @on_error_block&.call e, step.to_sym, *arguments
    raise
  end

  # @private
  def self.uuid() SecureRandom.uuid end

  def self.step(name, &block)
    _steps[name] = block
  end

  def step_count
    @step_count ||= begin
      raise 'arguments not set' unless arguments

      visitor = StepCountVisitor.new
      g       = SequentialBuilder.new(self, visitor)
      g.build! { perform(*arguments) }
      visitor.count
    end
  end

  private

  delegate :run, :sequential, :parallel, to: :@current_builder

  def graph
    @graph ||= begin
      graph = RGL::DirectedAdjacencyGraph.new
      class << graph
        def vertex_id(v)
          v.id
        end
      end

      steps = workflow_steps
      steps.each do |step|
        graph.add_vertex step
      end
      WorkflowStep.connection.execute('SELECT step_id, dependency_id FROM workflow_dependencies').each do |result|
        step = steps.detect { |s| s.id == result['step_id'] }
        dep  = steps.detect { |s| s.id == result['dependency_id'] }
        graph.add_edge dep, step
      end
      graph
    end
  end

  def workflow_steps
    WorkflowStep.where(workflow_uuid: id)
  end

  class StepVisitor
    def visit_step(builder, step_name, args)
    end

    def visit_intermediate_step(builder1, builder2)
    end
  end

  class StepBuilderVisitor < StepVisitor
    def visit_step(workflow, builder, step_name, args)
      builder.steps << WorkflowStep.create!(workflow: workflow, step_name: step_name, arguments: args)
    end

    def visit_intermediate_step(workflow, builder1, builder2)
      intermediate = WorkflowStep.create!(workflow: workflow)
      builder1.connect_successor! intermediate
      builder2.connect_predecessor! intermediate
    end
  end

  class StepCountVisitor < StepVisitor
    attr_reader :count

    def initialize(*)
      super
      @count = 0
    end

    def visit_step(*)
      @count += 1
    end

    def visit_intermediate_step(*)
      @count += 1
    end
  end

  class Builder
    attr_accessor :steps

    def initialize(workflow, visitor)
      @workflow = workflow
      @steps    = Array.new
      @visitor  = visitor
    end

    def sequential() yield end
    def parallel() yield end

    def run(step_name, *args)
      @visitor.visit_step @workflow, self, step_name, args
    end

    def build!
      builder = @workflow.instance_variable_get :@current_builder
      @workflow.instance_variable_set :@current_builder, self
      yield
      @workflow.instance_variable_set :@current_builder, builder
    end
  end

  class SequentialBuilder < Builder
    def parallel(&block)
      builder = ParallelBuilder.new(@workflow, @visitor)
      builder.build!(&block)
      steps << builder
    end

    def connect!
      steps.each_cons(2) do |(a, b)|
        if a.kind_of?(WorkflowStep) && b.kind_of?(WorkflowStep)
          a.successors = [b]
        elsif a.kind_of?(WorkflowStep) && b.kind_of?(ParallelBuilder)
          b.connect_predecessor! a
        elsif a.kind_of?(ParallelBuilder) && b.kind_of?(WorkflowStep)
          a.connect_successor! b
        elsif a.kind_of?(ParallelBuilder) && b.kind_of?(ParallelBuilder)
          @visitor.visit_intermediate_step(@workflow, a, b)
        else
          raise "Unexpected pair (#{a.inspect}, #{b.inspect})"
        end
      end
    end

    def connect_predecessor!(predecessor)
      case steps.first
        when WorkflowStep
          predecessor.successors << steps.first
        when ParallelBuilder
          steps.first.connect_predecessor!(predecessor)
      end
    end

    def connect_successor!(successor)
      case steps.last
        when WorkflowStep
          steps.last.successors << successor
        when ParallelBuilder
          steps.last.connect_successor!(successor)
      end
    end
  end

  class ParallelBuilder < Builder
    def sequential(&block)
      builder = SequentialBuilder.new(@workflow, @generator)
      builder.build!(&block)
      steps << builder
    end

    def connect_predecessor!(predecessor)
      steps.each do |step|
        case step
          when WorkflowStep
            predecessor.successors << step
          when SequentialBuilder
            step.connect_predecessor! predecessor
          else
            raise "Unexpected predecessor #{predecessor.inspect}"
        end
      end
    end

    def connect_successor!(successor)
      steps.each do |step|
        case step
          when WorkflowStep
            step.successors << successor
          when SequentialBuilder
            step.connect_successor! successor
          else
            raise "Unexpected predecessor #{predecessor.inspect}"
        end
      end
    end
  end
end
