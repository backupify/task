require 'values'

module Task
  module Generator
    include ::Enumerable

    def append(*generators)
      CombinedGenerator.new([self] + generators)
    end
  end

  class CombinedGenerator < Value.new(:generators)
    include Generator

    def each
      generators.each do |generator|
        generator.each { |t| yield t }
      end
    end
  end
end
