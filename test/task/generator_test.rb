require 'test_helper'

module Task
  class GeneratorTest < Minitest::Should::TestCase
    class TestTask
      include Task
    end

    class TestGenerator < Value.new(:id)
      include Generator

      def each
        yield TestTask.build(task_list: 'list', id: id, data: { a: 1 })
      end
    end

    context 'a task generator' do
      should 'yield tasks' do
        tasks = TestGenerator.new('id').to_a
        assert_equal 1, tasks.count
        assert_equal 'id', tasks.first.id
      end

      should 'be appendable to other generators' do
        gen = TestGenerator.new(1).append(TestGenerator.new(2))
        tasks = gen.to_a

        assert_equal 2, tasks.count
        assert_equal %w(1 2), tasks.map(&:id)
      end
    end
  end
end
