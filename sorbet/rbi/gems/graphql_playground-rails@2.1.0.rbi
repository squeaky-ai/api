# typed: false

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `graphql_playground-rails` gem.
# Please instead update this file by running `bin/tapioca gem graphql_playground-rails`.

# source://graphql_playground-rails//lib/graphql_playground/rails/engine.rb#1
module GraphqlPlayground; end

# source://graphql_playground-rails//lib/graphql_playground/rails/engine.rb#2
module GraphqlPlayground::Rails
  class << self
    # Returns the value of attribute config.
    #
    # source://graphql_playground-rails//lib/graphql_playground/rails.rb#8
    def config; end

    # Sets the attribute config
    #
    # @param value the value to set the attribute config to.
    #
    # source://graphql_playground-rails//lib/graphql_playground/rails.rb#8
    def config=(_arg0); end

    # @yield [config]
    #
    # source://graphql_playground-rails//lib/graphql_playground/rails.rb#10
    def configure; end

    # source://railties/7.0.4.3/lib/rails/engine.rb#405
    def railtie_helpers_paths; end

    # source://railties/7.0.4.3/lib/rails/engine.rb#394
    def railtie_namespace; end

    # source://railties/7.0.4.3/lib/rails/engine.rb#409
    def railtie_routes_url_helpers(include_path_helpers = T.unsafe(nil)); end

    # source://railties/7.0.4.3/lib/rails/engine.rb#397
    def table_name_prefix; end

    # source://railties/7.0.4.3/lib/rails/engine.rb#401
    def use_relative_model_naming?; end
  end
end

class GraphqlPlayground::Rails::ApplicationController < ::ActionController::Base
  def get_endpoint_url; end
  def index; end

  private

  # source://actionview/7.0.4.3/lib/action_view/layouts.rb#328
  def _layout(lookup_context, formats); end

  class << self
    # source://activesupport/7.0.4.3/lib/active_support/callbacks.rb#68
    def __callbacks; end

    # source://actionpack/7.0.4.3/lib/abstract_controller/helpers.rb#11
    def _helper_methods; end

    # source://actionpack/7.0.4.3/lib/action_controller/metal.rb#210
    def middleware_stack; end
  end
end

module GraphqlPlayground::Rails::ApplicationController::HelperMethods
  include ::ActionText::ContentHelper
  include ::ActionText::TagHelper
  include ::ActionController::Base::HelperMethods

  def get_endpoint_url(*args, **_arg1, &block); end
end

# source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#3
class GraphqlPlayground::Rails::Config
  # @return [Config] a new instance of Config
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#24
  def initialize; end

  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#48
  def all_settings; end

  # Returns the value of attribute csrf.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def csrf; end

  # Sets the attribute csrf
  #
  # @param value the value to set the attribute csrf to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def csrf=(_arg0); end

  # @example Adding a header to the request
  #   config.headers["My-Header"] = -> (view_context) { "My-Value" }
  # @return [Hash<String => Proc>] Keys are headers to include in GraphQL requests, values are `->(view_context) { ... }` procs to determin values
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#8
  def headers; end

  # @example Adding a header to the request
  #   config.headers["My-Header"] = -> (view_context) { "My-Value" }
  # @return [Hash<String => Proc>] Keys are headers to include in GraphQL requests, values are `->(view_context) { ... }` procs to determin values
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#8
  def headers=(_arg0); end

  # Returns the value of attribute logo.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def logo; end

  # Sets the attribute logo
  #
  # @param value the value to set the attribute logo to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def logo=(_arg0); end

  # Returns the value of attribute playground_css_url.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def playground_css_url; end

  # Sets the attribute playground_css_url
  #
  # @param value the value to set the attribute playground_css_url to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def playground_css_url=(_arg0); end

  # Returns the value of attribute playground_js_url.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def playground_js_url; end

  # Sets the attribute playground_js_url
  #
  # @param value the value to set the attribute playground_js_url to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def playground_js_url=(_arg0); end

  # Returns the value of attribute playground_version.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def playground_version; end

  # Sets the attribute playground_version
  #
  # @param value the value to set the attribute playground_version to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def playground_version=(_arg0); end

  # Call defined procs, add CSRF token if specified
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#36
  def resolve_headers(view_context); end

  # Returns the value of attribute settings.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def settings; end

  # Sets the attribute settings
  #
  # @param value the value to set the attribute settings to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def settings=(_arg0); end

  # Returns the value of attribute title.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def title; end

  # Sets the attribute title
  #
  # @param value the value to set the attribute title to.
  #
  # source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#10
  def title=(_arg0); end
end

# source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#16
GraphqlPlayground::Rails::Config::CSRF_TOKEN_HEADER = T.let(T.unsafe(nil), Hash)

# source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#12
GraphqlPlayground::Rails::Config::DEFAULT_HEADERS = T.let(T.unsafe(nil), Hash)

# source://graphql_playground-rails//lib/graphql_playground/rails/config.rb#20
GraphqlPlayground::Rails::Config::DEFAULT_SETTINGS = T.let(T.unsafe(nil), Hash)

# source://graphql_playground-rails//lib/graphql_playground/rails/engine.rb#3
class GraphqlPlayground::Rails::Engine < ::Rails::Engine
  class << self
    # source://activesupport/7.0.4.3/lib/active_support/callbacks.rb#68
    def __callbacks; end
  end
end

# source://graphql_playground-rails//lib/graphql_playground/rails/version.rb#3
GraphqlPlayground::Rails::VERSION = T.let(T.unsafe(nil), String)
