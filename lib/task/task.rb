require 'virtus'
require 'active_support/concern'
require_relative 'data_interface/interface'

module Task
  # A Task represents a task to be performed. The task can be serialized as JSON to be passed to
  # other processes to complete, and can be stored in Cassandra as a means of ensuring "at-least-once"
  # task completion for this task. So, an example lifecycle of a task would be:
  #   1) A task is generated in a "master" job
  #   2) The master job saves the task, providing a record that the task was generated.
  #   3) The master job passes the task to another job to complete the task.
  #   4) The worker job completes task, removing the record for that task.
  #   5) If the worker job fails, the task is not completed and so the record for it persists.
  #   6) A subsequent job can fetch the list of tasks, returning the tasks that failed to complete.
  #      This job could either serialize them to be completed by other jobs, or complete them directly.
  #
  # A task has a unique id, belongs to a task list that group similar tasks together, and has data
  # associated with it.
  #
  # @example Defining a type of Task
  #   class MyDeleteTask
  #     include Task::Task
  #     # This task has the item_id data field, representing the item to delete
  #     data_attr_reader :item_id
  #   end
  #
  # @example Creating a task
  #   my_task = MyDeleteTask.build(:id => 'my_id', :task_list => "#{service.id}-delete", :item_id => '123')
  #
  # @example Serializing and deserializing a task
  # # In the process that generated the task
  # serialized = my_task.as_hash
  #
  # # In the process that acts on the hash
  # my_task_copy = Task::Task.from_hash(serialized)
  #
  # @example Saving a task
  # my_task.save
  #
  # @example Fetching a single task that has been saved
  # Task::DataInterface::Interface.new.find(task_list, task_id)
  #
  # @example Fetching all tasks for a task list
  # Task::DataInterface::Interface.new.all(task_list)
  #
  # @example Completing a task, so that it is not longer fetchable
  # my_task.complete
  #
  module Task
    extend ActiveSupport::Concern
    include Virtus.module

    attribute :task_list, String
    attribute :id, String
    attribute :data, Hash[Symbol => Object]

    module ClassMethods
      # Instantiate an instance of this Task subclass.
      # @param options [Hash] Options to instantiate this Task. :task_list and :id are required;
      #   other arguments will be passed as data to the task.
      # @option options [String] :task_list
      # @option options [String] :id
      def build(options)
        task_list = options.delete(:task_list)
        id = options.delete(:id) || SecureRandom.hex
        new(task_list: task_list, id: id, data: options)
      end

      # Instantiate an instance of this Task subclass and save it to the datastore.
      # @param options [Hash] Options to instantiate this Task. :task_list and :id are required;
      #   other arguments will be passed as data to the task.
      # @option options [String] :task_list
      # @option options [String] :id
      def create(options)
        task = build(options)
        task.save
        task
      end

      # Defines an attr reader instance method for a field in the data hash.
      #
      # @example
      #    class MyTask
      #      include Task::Task
      #      data_attr_reader :my_data_field
      #    end
      #
      # @param attr_name [Symbol] The attr name of the data field which will be used.
      def data_attr_reader(attr_name)
        define_method(attr_name) { data[attr_name] }
      end
    end

    # Creates a Task object from the provided hash. Generally, this task object should NOT be
    # constructed manually using this method. Rather, this provides a way to reconstitute a task
    # that was previously serialized using the #as_hash method.
    #
    # @example
    #   class MyTask
    #     include Task::Task
    #     data_attr_reader :my_data_field
    #   end
    #   my_task = MyTask.new(:task_list => 'my_task_list', )

    #
    # @param task_hash [Hash] Should contain the :task_list, :id, :type, and :data fields
    # @return [Task::Task] The task object.
    def self.from_hash(task_hash)
      task_hash = task_hash.dup
      type = task_hash.delete(:type)
      type.constantize.new(task_hash)
    end

    # Returns the task with the given id
    # @param [String] task_list
    # @param [String] task_id
    # @return [Task::Task|NilClass]
    def self.find(task_list, id)
      interface.find(task_list, id)
    end

    # Returns all tasks for the provided task list
    # @param [String] task_list
    # @return [Enumerator::Lazy<Task::Task>]
    def self.all(task_list)
      interface.all(task_list)
    end

    # The Data Interface used
    # @return [Task::DataInterface::Interface]
    def self.interface
      DataInterface::Interface.new
    end

    # Executes this task
    # @param options [Hash] Options specific to the execution of this task
    def execute(options = {})
      raise NotImplementedError.new('execute method not implemented')
    end

    # Serialized this Task as a hash
    # @return [Hash]
    def as_hash
      attributes.merge(type: self.class.to_s)
    end

    # Saves this task to the data store.
    # @return [NilClass]
    def save
      Task.interface.store(self)
      nil
    end


    # Marks this task as complete, removing it from the datastore
    # @return [NilClass]
    def complete
      Task.interface.delete(task_list, id)
      nil
    end
  end
end
