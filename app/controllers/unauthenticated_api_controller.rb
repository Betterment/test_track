class UnauthenticatedApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :return_json

  private

  def return_json
    request.format = :json
  end

  def render_errors(model)
    render json: { errors: model.errors }, status: :unprocessable_entity
  end
end
