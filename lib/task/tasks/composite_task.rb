require_relative '../task'

module Task::Tasks
  class CompositeTask
    include Task::Task

    data_attr_reader :child_task_list

    def execute(opts = {})
      Task::Task.all(child_task_list).each do |task|
        task.execute(opts)
        task.complete
      end
    end
  end
end
