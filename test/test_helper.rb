require 'rubygems'
require 'pry'
require 'minitest/autorun'
require 'minitest/should'

require 'task'

require 'cassava'

class Minitest::Should::TestCase
  def self.xshould(*args)
    puts "Disabled test: #{args}"
  end
end

def session_for_keyspace(keyspace = 'test_tasks')
  c = Cassandra.cluster(port: 9242)
  c.connect(keyspace)
end

def initialize_task_table

  # Default to the 'test_tasks' keyspace
  Task::DataInterface::Interface.adapter_builder = ->(options) do
    session = Cassandra.cluster(options.merge(port: 9242)).connect(options[:keyspace] || 'test_tasks')
    Task::DataInterface::CassandraAdapter.new(client: Cassava::Client.new(session))
  end

  sess = session_for_keyspace(nil)
  sess.execute('DROP KEYSPACE test_tasks') rescue nil
  sess.execute("CREATE KEYSPACE test_tasks with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")
  session_for_keyspace.execute([
    'CREATE TABLE tasks (',
    'task_list text,',
    'id text,',
    'data text,',
    'type text,',
    'PRIMARY KEY ((task_list), id, type)',
    ')'
  ].join("\n"))
end

def clear_task_table
  sess = session_for_keyspace('test_tasks')
  sess.execute('DROP TABLE tasks')
end
