# frozen_string_literal: true

class GraphqlController < ApplicationController
  def execute
    StackProf.run(mode: :cpu, raw: true, out: 'tmp/stackprof.dump') do
      variables = prepare_variables(params[:variables])

      render json: SqueakySchema.execute(
        params[:query],
        variables:,
        operation_name: params[:operationName],
        context: { current_user:, request: }
      )
    end
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

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
