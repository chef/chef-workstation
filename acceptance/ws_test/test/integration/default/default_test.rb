# # encoding: utf-8

describe command('chef-run --version') do
  its('stdout') { should match (/chef-run/) }
end
