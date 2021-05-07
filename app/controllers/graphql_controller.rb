# frozen_string_literal: true

# The controller responsible for handling all the GraphQL requests.
# Every request will attempt to fetch the user from the Authorization
# header, although it is the responsibility of the Query/Mutation
# to ensure the user is properly authorized
class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = { current_user: current_user }
    result = SqueakySchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: { errors: [{ message: error.message, backtrace: error.backtrace }], data: {} }, status: 500
  end

  def current_user
    header = request.headers['Authorization']
    bearer = header.split('Bearer ').last if header

    return unless bearer

    token = JsonWebToken.decode(bearer)
    User.find(token[:id])
  rescue StandardError => e
    logger.error e
    nil
  end
end
