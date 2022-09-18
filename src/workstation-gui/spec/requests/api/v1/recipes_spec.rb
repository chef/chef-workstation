require "rails_helper"

RSpec.describe "Api::V1::Recipes", type: :request do
  describe "GET /api/v1/cookbook/recipes" do
    it "returns a successful response of all valid cookbook path" do
      params =
        {
          "filepath": "/Users/prsingh/Documents/repo-for-app-linking/chef-repo1/cookbooks/cookbook5", # ony in valid path case
        }
      get "/api/v1/cookbook/recipes", params: params
      expect(response).to be_successful
    end

    it "returns a successful response of all invalid cookbook path" do
      params =
        {
          "filepath": "/Users/prsingh/Documents/repo-for-app-linking/chef-repo1/cookbooks/cookbookrandom", # ony in valid path case
        }
      get "/api/v1/cookbook/recipes", params: params
      expect(response.status).to eq(422)
    end

    it "returns a successful response of no filepath given in params" do

      get "/api/v1/cookbook/recipes"
      expect(response.status).to eq(422)
    end
  end
end
