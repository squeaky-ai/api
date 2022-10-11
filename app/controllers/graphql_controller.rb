# frozen_string_literal: true

class GraphqlController < ApplicationController
  def execute
    variables = prepare_variables(params[:variables])

    response = SqueakySchema.execute(
      params[:query],
      variables:,
      operation_name: params[:operationName],
      context: { current_user:, request: }
    )

    # There are mega gains to be had from using Oj
    # here instead of whatever serializer rails uses
    # by default
    render json: serialize(response)
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  def serialize(response)
    Stats.timer('serialize_response') do
      Oj.dump(response.to_h)
    end
  end

  def prepare_variables(variables_param)
    case variables_param
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
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
end
