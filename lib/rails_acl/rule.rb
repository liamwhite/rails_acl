module RailsACL
  # Rule class representing actions doable on a subject.
  class SubjectRule # :nodoc:
    def initialize
      @actions = {}
    end

    def add_clause(action, block)
      @actions[action] = (block || true)
    end

    def authorized?(action, subject, args)
      block = @actions[:manage] || @actions[action]
      return false unless block
      return true if block == true
      return !!block.call(*[subject, *args])
    end
  end

  # Fake rule representing nothing matched a subject when looking up its ability.
  class NullRule # :nodoc:
    def self.authorized?(*)
      false
    end
  end
end
