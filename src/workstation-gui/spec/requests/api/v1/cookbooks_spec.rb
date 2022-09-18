require "rails_helper"

RSpec.describe "Api::V1::Cookbooks", type: :request do
  describe "GET /api/v1/repositories/cookbooks" do
    it "returns a successful response of all cookbooks irrespective of repository " do
      get "/api/v1/repositories/cookbooks"
      expect(response).to be_successful
    end

    it "returns a successful response of all cookbooks with repository(valid)" do
      # NOTE ADD, VALID JSON ELSE COMMENT OUT
      # if false
      params = {
                "repo_id": "9ac39ecf-f1a0-497a-9721-2321e7ba7bb0",
               }
      get "/api/v1/repositories/cookbooks", params: params
      expect(response).to be_successful
      # end
    end

    it "returns a failure response of all cookbooks with repository(invalid)" do
      params = {
              "repo_id": "9ac39ecf-f1a0-497a-9721",
              }
      get "/api/v1/repositories/cookbooks", params: params
      expect(JSON.parse(response.body)["cookbooks"]).to eq([])
    end
  end
end
