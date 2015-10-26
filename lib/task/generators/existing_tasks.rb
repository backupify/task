require 'values'
require_relative '../generator'

module Task::Generators
  class ExistingTasks < Value.new(:task_list)
    include ::Task::Generator

    def each
      Task::Task.all(task_list).each { |t| yield t }
    end
  end
end
