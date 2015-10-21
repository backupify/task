require 'test_helper'

module Task::DataInterface
  class InterfaceTest < Minitest::Should::TestCase
    class TestTask
      include Task::Task
    end

    setup do
      initialize_task_table

      # Default to the 'test_tasks' keyspace
      Task::DataInterface::Interface.adapter_builder = ->(options) do
        session = Cassandra.cluster(options.merge(port: 9242)).connect(options[:keyspace] || 'test_tasks')
        CassandraAdapter.new(client: Cassava::Client.new(session))
      end

      @interface = Task::DataInterface::Interface.new
    end

    teardown do
      clear_task_table
    end

    context 'storing and fetching tasks' do
      should 'allow a task to stored and fetched' do
        t = TestTask.new(id: 'id', task_list: 'test', data: { x: 1 })
        @interface.store(t)
        fetched = @interface.all('test').to_a

        assert_equal 1, fetched.count

        task = fetched.first

        %w(id task_list data).each { |field| assert_equal t.send(field), task.send(field) }
      end
    end

    context '#all' do
      should 'return a lazy enumerator' do
        assert_equal Enumerator::Lazy, @interface.all('test').class
      end

      should 'return all tasks in arbitrary order' do
        TestTask.new(id: 'id', task_list: 'test', data: { x: 1 }).save
        TestTask.new(id: 'id2', task_list: 'test', data: { x: 1 }).save

        assert_equal %w(id id2).to_set, @interface.all('test').map(&:id).to_set
      end

      should 'not return tasks from other task lists' do
        TestTask.new(id: 'id', task_list: 'test', data: { x: 1 }).save
        TestTask.new(id: 'id2', task_list: 'test2', data: { x: 1 }).save

        assert_equal %w(id), @interface.all('test').map(&:id).to_a
      end
    end

    context '#find' do
      should 'find a specific task if it exists' do
        t = TestTask.new(id: 'id', task_list: 'test', data: { x: 1 })
        t.save
        assert_equal t.attributes, @interface.find('test', 'id').attributes
      end

      should 'return nil if the task does not exist' do
        assert_nil @interface.find('test', 'id')
      end
    end

    context '#delete' do
      should 'remove a task' do
        t = TestTask.new(id: 'id', task_list: 'test', data: { x: 1 })
        t.save

        assert @interface.find('test', 'id')
        @interface.delete('test', 'id')
        refute @interface.find('test', 'id')
      end

      should 'do nothing for tasks that do not exist ' do
        refute @interface.find('test', 'id')
      end
    end
  end
end
