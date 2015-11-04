require 'test_helper'

module Task::Tasks
  class CompositeTaskTest < Minitest::Should::TestCase

    class ExampleTask
      include Task::Task

      class << self
        attr_accessor :executed_count
      end

      def execute(opts = {})
        self.class.executed_count += 1
        id
      end

      data_attr_reader :test_field
    end

    context 'a composite task' do

      setup do
        initialize_task_table
        ExampleTask.executed_count = 0
      end

      teardown do
        clear_task_table
      end

      should 'execute child tasks from the specified list when executed' do
        ExampleTask.create(task_list: 'a', id: '1')
        ExampleTask.create(task_list: 'a', id: '2')

        CompositeTask.build(child_task_list: 'a', task_list: 'x').execute

        assert_equal 2, ExampleTask.executed_count
      end

      should 'not execute child tasks from other task lists' do
        ExampleTask.create(task_list: 'a', id: '1')
        ExampleTask.create(task_list: 'a', id: '2')
        ExampleTask.create(task_list: 'b', id: '3')

        CompositeTask.build(child_task_list: 'a', task_list: 'x').execute

        assert_equal 2, ExampleTask.executed_count
      end

      should 'return the results of each executed child task' do
        ExampleTask.create(task_list: 'a', id: '1')
        ExampleTask.create(task_list: 'a', id: '2')

        child_ids = CompositeTask.build(child_task_list: 'a', task_list: 'x').execute
        assert_equal %w(1 2), child_ids
      end
    end
  end
end
