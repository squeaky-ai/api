# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |source|
      if source == Rails.application.config.web_host
        # If the request is coming from our own domain
        # we can return early and skip the call to the
        # database
        source
      else
        # If the request is external, we want to make sure
        # it is coming from one of the sites in our app.
        # Regular auth will still apply even if the cors
        # is correct
        site = Site.exists?(url: source.sub('www.', ''))
        Rails.logger.info "Request is using CORS, #{source} is #{site ? 'valid' : 'invalid'}"
        source ? site : false
      end
    end

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end
