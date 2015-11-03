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

      context 'serialization and deserialization' do
        setup do
          @task = ExampleTask.build(task_list: 'a', id: 'id', test_field: 1)
          @recreated = Task.from_hash(@task.as_hash)
        end

        should 'recreate a task from its serialized hash form' do
          assert_equal @task.attributes, @recreated.attributes
        end

        should 'reserialize the class of the task' do
          assert_equal @task.class, @recreated.class
        end

        should 'raise an error if the serialized task class does not exist' do
          task_hash = @task.as_hash.merge(type: 'NotAClass')
          assert_raises(NameError) { Task.from_hash(task_hash) }
        end
      end

      context '#create' do
        setup do
          initialize_task_table
        end

        teardown do
          clear_task_table
        end

        should 'save the task to the datastore' do
          task = ExampleTask.create(task_list: 'a')
          all_tasks = Task.all(task.task_list).to_a

          assert_equal 1, all_tasks.count
          assert_equal task.attributes, all_tasks.first.attributes
        end
      end
    end
  end
end
