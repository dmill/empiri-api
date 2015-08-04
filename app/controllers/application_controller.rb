class ApplicationController < ActionController::Metal
  include AbstractController::Rendering         # Basic rendering
  include ActionController::Rendering           # necessary for rendering non-200 statuses
  include ActionController::Renderers::All      # `render :json` and similar
  include ActionController::ConditionalGet      # `stale?`
  include ActionController::RackDelegation      # Support for `request` and `response`
  include ActionController::Caching             # Basic controller caching
  include ActionController::MimeResponds        # Enable `respond_to`
  include ActionController::StrongParameters

  # Before callbacks should also be executed the earliest as possible, so
  # also include them at the bottom.
  include AbstractController::Callbacks         # `before_filter` and friends

  # Append rescue at the bottom to wrap as much as possible.
  include ActionController::Rescue

  # Add instrumentations hooks at the bottom, to ensure they instrument
  # all the methods properly.
  include ActionController::Instrumentation

  # Params wrapper should come before instrumentation so they are
  # properly showed in logs
  include ActionController::ParamsWrapper

  ActiveSupport.run_load_hooks(:action_controller, self)
end
