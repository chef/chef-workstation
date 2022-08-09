class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def authenticate_api_user!
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    decoded = Auth::JwtToken.decode(header)
    access_key = Rails.application.credentials.access_key.to_s
    if decoded['access_key'] != access_key
      render json: { error: 'Invalid auth credentials' }, status: :unauthorized
    end
  rescue JWT::DecodeError => e
    render json: { error: "Unable to process the auth token: #{e.message}" }, status: :unauthorized
  end
end
