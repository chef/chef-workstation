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
module Auth
  class JwtToken
    SECRET_KEY = Rails.application.credentials.secret_key_base.to_s

    class << self
      def encode(payload, exp = 1.week.from_now)
        payload[:exp] = exp.to_i

        JWT.encode(payload, SECRET_KEY)
      end

      def decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]

        decoded.to_h.with_indifferent_access
      end
    end
  end
end
