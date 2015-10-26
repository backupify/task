require 'values'

module Task
  module Generator
    include ::Enumerable

    def append(*generators)
      Generators::CombinedGenerator.new([self] + generators)
    end
  end

  module Generators
    class CombinedGenerator < Value.new(:generators)
      include Generator

      def each
        generators.each do |generator|
          generator.each { |t| yield t }
        end
      end
    end
  end
end
