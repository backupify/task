# Task

Task provides a toolbox for generating, tracking and serializing tasks to be performed.
It is NOT a job queuing framework, a la resque or qless, and does not provide ways to execute tasks
in a distributed fashion. Rather, Task could be used with such a framework to provide "at-least-once"
task execution guarantees, or to perform multiple, lightweight tasks within a single job.

An example task lifecycle could be follows:

1. A task is generated
2. The task is saved to a backing data store, recording that it has been generated and should be completed.
3. The task is serialized (as JSON) and passed to another process or host to complete.
4. The worker process completes the task, marking it as completed in the backing data store.

OR

3. The worker process fails to complete the task.
4. A subsequent worker can fetch the task from the backing data store and attempts to complete it.

Out of the box, Task uses Cassandra as the backing data store, but other backends could be implemented.
Cassandra provides stronger durability guarantees than some other data stores (for example, Redis). Additionally,
Cassandra prefers write-heavy workloads. In the workload described above, A task need only be read from the
datastore if it fails to complete initially. In situations where most tasks complete on the first attempt,
the majority of datastore operations will be writes. However, because Task does not enforce a usage pattern,
this could be usage-dependent.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'task'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install task

## Usage

### Defining and Creating a Task

To define a task, mix in the Task module:

```ruby
class FetchFile
  include Task::Task

  data_attr_reader :external_host
  data_attr_reader :filename
end
```

A task contains a set of data key-value pairs; The `data_attr_reader` helper provides accessors for various expected
data fields, but is not required.

To build a task, we invoke the build method:

```ruby
file_task = FetchFile.build(
  id: 'file1',
  task_list: 'datto.com',
  external_host: 'datto.com',
  filename: 'file1.txt')
```

Here, the task belongs to the 'datto.com' task list. The ID of the task should be unique across the task list (if one
is not specified, a UUID will be used). Other provided fields just become part of the data of task; this is just syntactic
sugar for:

```ruby
file_task = FetchFile.new(
  id: 'file1',
  task_list: 'datto.com',
  data: { external_host: 'datto.com', filename: 'file1.txt' })
```

On the task object, the `data_attr_readers` allow access to data fields, so `file_task.data[:external_host]` and
`file_task.external_host` are equivalent.

### Saving and Loading Tasks from the Datastore

To save to the datastore:

```ruby
file_task.save
```

To fetch a particular task (by id) from the datastore:

```ruby
file_task = Task::Task.find(task_list, id)
```

To fetch all tasks for a task list from the datastore:

```ruby
tasks_enumerator = Task::Task.all(task_list)
```

### Serializing and Deserializing Tasks

To serialize as a hash:

```ruby
task_hash = my_task.as_hash
```

To deserialize a task hash to the task that was originally serialized:

```ruby
my_task = Task::Task.from_hash(task_hash)
```

Task does not enforce a particular over the wire serialization format.

### Configuring the Datastore

The datastore interface is backed by an adapter. Which adapter is used, and how it is
constructed, is configurable, by specifying the adapter builder.

```ruby
Task::DataInterface::Interface.adapter_builder = ->(_options) do
  session = Cassandra.cluster(port: 1234, hosts: ['my_host']).connect('my_tasks')
  CassandraAdapter.new(client: Cassava::Client.new(session))
end
```

This example configures the CassandraAdapter to connect to Cassandra on port 1234 and host 'my_host', and to
use the keyspace 'my_tasks'. Similarly, a completely separate adapter could be used.

Additionally, data interface instances can be constructed by passing in an adapter, allowing different
adapters (or adapter configurations) to be used at once.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/backupify/task.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
