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
module Api
  module V1
    class AuthenticationController < ApiV1Controller
      before_action :validate_creds, only: %i{login}
      skip_before_action :authenticate_api_requests!, only: %i{login}

      def login
        access_key = Rails.application.credentials.access_key.to_s

        if params[:access_key] == access_key
          token = Auth::JwtToken.encode(access_key: params[:access_key])

          render json: {
            data: {
              token: token,
            },
            message: "success",
            code: "200",
          }
        else
          render json: { message: "Invalid credentials", code: 401 }, status: :unauthorized
        end
      end

      private

      def validate_creds
        unless params.key?(:access_key)
          render json: { errors: "Access key is required", code: 401 }, status: :unauthorized
        end
      end
    end
  end
end

