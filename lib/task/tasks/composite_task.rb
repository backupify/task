require_relative '../task'

module Task::Tasks
  class CompositeTask
    include Task::Task

    data_attr_reader :child_task_list

    # @param opts [Hash] Options to pass to the execute method of each child task
    # @return [Array] The sequence of return values from each task execution
    def execute(opts = {})
      (Task::Task.all(child_task_list).map do |task|
        task_result = task.execute(opts)
        task.complete
        task_result
       end).force
    end
  end
end
