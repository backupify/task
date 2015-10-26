require 'test_helper'

module Task::Generators
  class ExistingTasksTest < Minitest::Should::TestCase

    class ExampleTask
      include Task::Task
    end

    setup do
      initialize_task_table
    end

    teardown do
      clear_task_table
    end

    context 'the existing tasks generator' do
      should 'generate all tasks for the task list' do
        task1 = ExampleTask.build(task_list: 'task_list', id: 'id1')
        task1.save
        task2 = ExampleTask.build(task_list: 'task_list', id: 'id2')
        task2.save

        gen = Task::Generators::ExistingTasks.new('task_list')
        assert_equal [task1.attributes, task2.attributes], gen.to_a.map(&:attributes)
      end

      should 'not generate tasks from other task lists' do
        task1 = ExampleTask.build(task_list: 'task_list', id: 'id1')
        task1.save
        task2 = ExampleTask.build(task_list: 'task_list2', id: 'id2')
        task2.save

        gen = Task::Generators::ExistingTasks.new('task_list')
        assert_equal [task1.attributes], gen.to_a.map(&:attributes)
      end

    end
  end
end
