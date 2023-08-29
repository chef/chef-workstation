source "https://rubygems.org"

# Everything except AIX and Windows
group(:ruby_shadow) do
  # if ruby-shadow does a release that supports ruby-3.0 this can be removed
  gem "ruby-shadow", git: "https://github.com/chef/ruby-shadow", branch: "lcg/ruby-3.0", platforms: :ruby
end

group :development do
  gem "chefstyle"
  gem "rake"
  # enable tests for the verification behavior in omnibus/verification
  gem "chef-cli"
  gem "rspec"

  gem "simplecov", require: false
end

