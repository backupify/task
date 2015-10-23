require 'values'

module Task::Generators
  class ExistingTask < Value.new(:task_list)
    include Generator

    def each
      Task::Task.all(task_list).each { |t| yield t }
    end
  end
end
