#
# Copyright:: Copyright Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class ApiV1Controller < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_api_requests!

  def authenticate_api_requests!
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    return render json: { error: "Missing authorization headers" }, status: :unauthorized if header.nil?

    decoded = Auth::JwtToken.decode(header)
    access_key = Rails.application.credentials.access_key.to_s
    if decoded["access_key"] != access_key
      render json: { message: "Invalid auth credentials", status: 401 }, status: :unauthorized
    end
  rescue JWT::DecodeError => e
    render json: { message: "Unable to process the auth token: #{e.message}", status: 401 }, status: :unauthorized
  end
end