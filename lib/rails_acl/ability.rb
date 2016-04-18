module RailsACL
  # This module is designed to be included into an Ability class. This will
  # provide the "can" methods for defining and checking abilities.
  module Ability
    # Check if the user has permission to perform a given action on an object.
    #
    #   can? :destroy, @project
    #
    # You can also pass the class instead of an instance (if you don't have one handy).
    #
    #   can? :create, Project
    #
    # Any additional arguments will be passed into the "can" block definition. This
    # can be used to pass more information about the user's request for example.
    #
    #   can? :create, Project, request.remote_ip
    #
    #   can :create, Project do |project, remote_ip|
    #     # ...
    #   end
    #
    # Not only can you use the can? method in the controller and view (see ControllerAdditions),
    # but you can also call it directly on an ability instance.
    #
    #   ability.can? :destroy, @project
    #
    # This makes testing a user's abilities very easy.
    #
    #   test "user can only destroy projects which he owns" do
    #     user = User.new
    #     ability = Ability.new(user)
    #     assert ability.can?(:destroy, Project.new(:user => user))
    #     assert ability.cannot?(:destroy, Project.new)
    #   end
    #
    def can?(action, subject, *args)
      return true if @allow_anything
      lookup_rule(subject).authorized?(action, args)
    end

    # Convenience method which works the same as "can?" but returns the opposite value.
    #
    #   cannot? :destroy, @project
    #
    def cannot?(*args)
      not can?(*args)
    end

    # Defines which abilities are allowed using two arguments. The first one is the action
    # you're setting the permission for, the second one is the class of object you're setting it on.
    #
    #   can :update, Article
    #
    # You can pass :all to match any object and :manage to match any action. Here are some examples.
    #
    #   can :manage, :all
    #   can :update, :all
    #   can :manage, Project
    #
    # You can pass a hash of conditions as the third argument. Here the user can only see active projects which he owns.
    #
    #   can :read, Project, :active => true, :user_id => user.id
    #
    # If the conditions hash does not give you enough control over defining abilities, you can use a block
    # along with any Ruby code you want.
    #
    #   can :update, Project do |project|
    #     project.groups.include?(user.group)
    #   end
    #
    # If the block returns true then the user has that :update ability for that project, otherwise s/he
    # will be denied access. The downside to using a block is that it cannot be used to generate
    # conditions for database queries.
    #
    # You can pass custom objects into this "can" method, this is usually done with a symbol
    # and is useful if a class isn't available to define permissions on.
    #
    #   can :read, :stats
    #   can? :read, :stats # => true
    #
    # IMPORTANT: A block will not be used when checking permission on a class.
    #
    #   can? :update, Project # => true
    #
    def can(action, subject, &block)
      rule_for(subject).add_clause(action, block)
    end

    def allow_anything!
      @allow_anything = true
    end

    def authorize!(action, subject, *args)
      raise AccessDenied if cannot?(action, subject, *args)
    end

    protected

    def subjects
      @subjects ||= {}
    end

    # Find or create a new rule for the specified subject.
    def rule_for(subject)
      subjects[subject] ||= Rule.new
    end

    # Look up a rule for the specified subject.
    def lookup_rule(subject)
      case subject
      when Symbol, Class
        subjects[subject] || NullRule
      else
        subjects[subject.class] || NullRule
      end
    end
  end
end
