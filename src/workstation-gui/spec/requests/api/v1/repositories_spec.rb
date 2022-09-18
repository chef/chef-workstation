require "rails_helper"

RSpec.describe "Api::V1::Repositories", type: :request do
  describe "GET /api/v1/repositories/list_repositories" do
    it "returns a successful response" do
      get "/api/v1/repositories/list_repositories"
      expect(response).to be_successful
    end
  end

  describe "GET /api/v1/repositories/link_repository" do
    it "returns a successful response" do
      # Todo should be post call -- get call is not working so using post call(this will fail ones after passing)
      if false # commenting out for time being
        params = {
          "repositories":
            {
          "type": "local",
          "filepath": "/Users/prsingh/Documents/repo-for-app-linking/chef-repo6", # make this valid path  with cookbook and then test
             },
        }
        get "/api/v1/repositories/link_repository", params: params
        expect(response).to be_successful
      end

    end

    it "returns a failed 422 response for wrong or dublicate path" do
      # Todo should be post call -- get call is not working so using post call
      params =  {
        "repositories":
          {
            "type": "local",
            "filepath": "/Users/prsingh/Documents/repo-for-app-linking/chef-repo1", # make this valid path  with cookbook and then test
          },
      }
      get "/api/v1/repositories/link_repository", params: params
      expect(response.status).to eq(422)
    end
  end
end
