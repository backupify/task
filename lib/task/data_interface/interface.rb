require 'cassava'
require 'active_support/core_ext/class/attribute'
require_relative 'cassandra_adapter'

module Task::DataInterface
  class Interface
    attr_reader :adapter

    # The adapter builder function used to initialize the adapter based on the options provided to new.
    # By default, a CassandraAdapter will be used. For this default adapter builder, the following
    # arguments are supported:
    # * :keyspace - the keyspace to use; default is 'tasks'
    # * any arguments accepted by the #Cassandra.cluster method, including :port and :hosts
    class_attribute :adapter_builder
    self.adapter_builder = ->(options) do
      binding.pry
      session = Cassandra.cluster(options).connect(options[:keyspace] || 'tasks')
      CassandraAdapter.new(client: Cassava::Client.new(session))
    end

    # @option options [#store,#all,#find,#delete] :adapter adapter to use.
    #   Otherwise, the configured adapter builder will be used
    def initialize(options = {})
      @adapter = options[:adapter] || self.class.adapter_builder.call(options)
    end
    # Stores a task in the data store
    # @param [Task::Task] task
    def store(task)
      adapter.store(task)
    end

    # Returns all tasks for the provided task list
    # @param [String] task_list
    # @return [Enumerator::Lazy<Task::Task>]
    def all(task_list)
      adapter.all(task_list)
    end

    # Returns the task with the given id
    # @param [String] task_list
    # @param [String] task_id
    # @return [Task::Task|NilClass]
    def find(task_list, task_id)
      adapter.find(task_list, task_id)
    end

    # Deletes the task with the given id.
    # @param [String] task_list
    # @param [String] task_id
    def delete(task_list, task_id)
      adapter.delete(task_list, task_id)
    end
  end
end
