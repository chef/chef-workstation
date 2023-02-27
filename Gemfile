source "https://rubygems.org"

# proxifier gem is busted on ruby 3.1 and seems abandoned so use git fork of gem
gem "proxifier", git: "https://github.com/chef/ruby-proxifier", branch: "lcg/ruby-3"

group :development do
  gem "chefstyle"
  gem "rake"
  # enable tests for the verification behavior in omnibus/verification
  gem "chef-cli"
  gem "rspec"

  gem "simplecov", require: false
end

