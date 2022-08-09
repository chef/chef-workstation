class AuthenticationController < ApplicationController
  before_action :validate_creds, only: %i[login]
  before_action :authenticate_api_user!, only: %i[testing]

  def login
    access_key = Rails.application.credentials.access_key.to_s

    if params[:access_key] == access_key
      token = Auth::JwtToken.encode(access_key: params[:access_key])

      render json: {
        token: token
      }, status: :ok
    else
      render json: { errors: "Invalid credentials" }, status: :unauthorized
    end
  end

  def testing
    render json: {status: "okay", message: "success" }
  end

  private

  def validate_creds
    render json: { errors: "Access key is required"} unless params.key?(:access_key)
  end
end
