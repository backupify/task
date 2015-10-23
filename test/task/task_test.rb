require 'test_helper'

module Task
  class TaskTest < Minitest::Should::TestCase

    class ExampleTask
      include Task

      data_attr_reader :test_field
    end

    context 'a task' do
      should 'build correctly from specified args' do
        task = ExampleTask.build(task_list: 'a', id: 'id', test_field: 1)
        assert_equal 'a', task.task_list
        assert_equal 'id', task.id
        assert_equal({ test_field: 1 }, task.data)
      end

      should 'use a random uuid as id if none specified' do
        task = ExampleTask.build(task_list: 'a')
        assert task.id
      end

      should 'allow specified data fields to be read' do
        task = ExampleTask.build(task_list: 'a', id: 'id', test_field: 1)
        assert_equal 1, task.test_field
      end
    end
  end
end
