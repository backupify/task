require 'pyper'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'

module Task::DataInterface
  class CassandraAdapter
    attr_reader :client, :tasks_table_name

    # @option opts [Cassava::Client] :client The Cassandra Client to use
    # @option opts [Symbol] :tasks_table_name The table name of the cassandra table containing the tasks
    #   Defaults to :tasks
    def initialize(opts = {})
      @client = opts[:client]
      @tasks_table_name = opts[:tasks_table_name] || :tasks
    end

    # (see Interface)
    def store(task)
      pipeline = Pyper::Pipeline.new

      # Serialize the attributes to be stored
      pipeline << Pyper::WritePipes::AttributeSerializer.new

      # Store the serialized attributes in the tasks table
      pipeline << Pyper::WritePipes::CassandraWriter.new(tasks_table_name, client)
      pipeline.push(task.as_hash)
    end

    # (see Interface)
    def delete(task_list, task_id)
      client.delete(:tasks).where(:task_list => task_list, :id => task_id).execute
    end

    # (see Interface)
    def all(task_list)
      read_pipe.push(:task_list => task_list).value
    end

    def find(task_list, task_id)
      read_pipe.push(:task_list => task_list, :id => task_id).value.first
    end

    private

    def read_pipe
      pipeline = Pyper::Pipeline.new

      # Read items from cassandra, as determined by the args pushed into the pipeline
      pipeline << Pyper::ReadPipes::CassandraItems.new(tasks_table_name, client)

      # Deserialize the data field into a hash
      pipeline << Pyper::ReadPipes::AttributeDeserializer.new('data' => Hash)

      # Deserialize items into Task objects
      pipeline << TaskDeserializer

      pipeline
    end

    class TaskDeserializer
      def self.pipe(items, status)
        items.map do |item|
          Task::Task.from_hash(item.with_indifferent_access)
        end
      end
    end
  end
end
