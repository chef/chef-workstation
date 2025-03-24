#!/usr/bin/env ruby

gem_home = Gem.paths.home

puts "fixing bundle installed gems in #{gem_home}"

# Install gems from git repos.  This makes the assumption that there is a <gem_name>.gemspec and
# you can simply gem build + gem install the resulting gem, so nothing fancy.  This does not use
# rake install since we need --conservative --minimal-deps in order to not install duplicate gems.
#
Dir["#{gem_home}/bundler/gems/*"].each do |gempath|
  matches = File.basename(gempath).match(/.*-[A-Fa-f0-9]{12}/)
  next unless matches

  gem_name = File.basename(Dir["#{gempath}/*.gemspec"].first, ".gemspec")
  # FIXME: should strip any valid ruby platform off of the gem_name if it matches

  next unless gem_name

  puts "re-installing #{gem_name}..."

  Dir.chdir(gempath) do
    # Only Windows-specific change (line added)
    gem_cmd = Gem.win_platform? ? "#{Gem.bindir}/gem.bat" : "gem"

    # Original build command (unchanged)
    system("#{gem_cmd} build #{gem_name}.gemspec") or raise "gem build failed"

    # Original install command with one Windows addition
    install_flags = "--conservative --minimal-deps --no-document"
    install_flags += " --platform ruby" if Gem.win_platform?
    system("#{gem_cmd} install #{gem_name}*.gem #{install_flags}") or raise "gem install failed"
  end
end
