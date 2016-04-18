module RailsACL
  # This module is automatically included into all controllers.
  # It also makes the "can?" and "cannot?" methods available to all views.
  module ControllerAdditions
    module ClassMethods
      # Add this to a controller to ensure it performs authorization through +authorized+! or +authorize_resource+ call.
      # If neither of these authorization methods are called, a RailsACL::AuthorizationNotPerformed exception will be raised.
      # This is normally added to the ApplicationController to ensure all controller actions do authorization.
      #
      #   class ApplicationController < ActionController::Base
      #     check_authorization
      #   end
      #
      # See skip_authorization_check to bypass this check on specific controller actions.
      #
      # Options:
      # [:+only+]
      #   Only applies to given actions.
      #
      # [:+except+]
      #   Does not apply to given actions.
      #
      # [:+if+]
      #   Supply the name of a controller method to be called. The authorization check only takes place if this returns true.
      #
      #     check_authorization :if => :admin_controller?
      #
      # [:+unless+]
      #   Supply the name of a controller method to be called. The authorization check only takes place if this returns false.
      #
      #     check_authorization :unless => :devise_controller?
      #
      def check_authorization(options = {})
        self.after_filter(options.slice(:only, :except)) do |controller|
          next if controller.instance_variable_defined?(:@_authorized)
          next if options[:if] && !controller.send(options[:if])
          next if options[:unless] && controller.send(options[:unless])
          raise AuthorizationNotPerformed, "This action failed the check_authorization because it did not authorize a resource. Add skip_authorization_check to bypass this check."
        end
      end

      # Call this in the class of a controller to skip the check_authorization behavior on the actions.
      #
      #   class HomeController < ApplicationController
      #     skip_authorization_check :only => :index
      #   end
      #
      # Any arguments are passed to the +before_filter+ it triggers.
      def skip_authorization_check(*args)
        self.before_filter(*args) do |controller|
          controller.instance_variable_set(:@_authorized, true)
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :can?, :cannot?, :current_ability if base.respond_to? :helper_method
    end

    # Raises a RailsACL::AccessDenied exception if the current_ability cannot
    # perform the given action. This is usually called in a controller action or
    # before filter to perform the authorization.
    #
    #   def show
    #     @article = Article.find(params[:id])
    #     authorize! :read, @article
    #   end
    #
    # A :message option can be passed to specify a different message.
    #
    #   authorize! :read, @article, :message => "Not authorized to read #{@article.name}"
    #
    # You can rescue from the exception in the controller to customize how unauthorized
    # access is displayed to the user.
    #
    #   class ApplicationController < ActionController::Base
    #     rescue_from RailsACL::AccessDenied do |exception|
    #       redirect_to root_url, :alert => exception.message
    #     end
    #   end
    #
    # See the load_and_authorize_resource method to automatically add the authorize! behavior
    # to the default RESTful actions.
    def authorize!(*args)
      @_authorized = true
      current_ability.authorize!(*args)
    end

    # Creates and returns the current user's ability and caches it. If you
    # want to override how the Ability is defined then this is the place.
    # Just define the method in the controller to change behavior.
    #
    #   def current_ability
    #     # instead of Ability.new(current_user)
    #     @current_ability ||= UserAbility.new(current_account)
    #   end
    #
    # Notice it is important to memoize the ability object so it is not
    # recreated every time.
    def current_ability
      @current_ability ||= ::Ability.new(current_user)
    end

    # Use in the controller or view to check the user's permission for a given action
    # and object.
    #
    #   can? :destroy, @project
    #
    # You can also pass the class instead of an instance (if you don't have one handy).
    #
    #   <% if can? :create, Project %>
    #     <%= link_to "New Project", new_project_path %>
    #   <% end %>
    #
    # If it's a nested resource, you can pass the parent instance in a hash. This way it will
    # check conditions which reach through that association.
    #
    #   <% if can? :create, @category => Project %>
    #     <%= link_to "New Project", new_project_path %>
    #   <% end %>
    #
    # This simply calls "can?" on the current_ability. See Ability#can?.
    def can?(*args)
      current_ability.can?(*args)
    end

    # Convenience method which works the same as "can?" but returns the opposite value.
    #
    #   cannot? :destroy, @project
    #
    def cannot?(*args)
      current_ability.cannot?(*args)
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include RailsACL::ControllerAdditions
  end
end
