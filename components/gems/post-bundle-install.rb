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
    system("gem build #{gem_name}.gemspec") or raise "gem build failed"
    system("gem install #{gem_name}*.gem --conservative --minimal-deps --no-document") or raise "gem install failed"
  end
end

# Handle resolv gem conflict with default ruby gem
puts "Checking resolv gem installation..."
resolv_info = `gem info resolv`

if resolv_info.include?("Installed at (default):") && resolv_info.include?("resolv (0.2.1)")
  # Extract the default gem path
  default_path = resolv_info.match(/Installed at \(default\): (.+)$/)[1]

  if default_path
    gemspec_path = File.join(default_path.strip, "specifications", "default", "resolv-0.2.1.gemspec")

    if File.exist?(gemspec_path)
      puts "Removing default resolv gemspec: #{gemspec_path}"
      File.delete(gemspec_path)
    end
  end

  puts "Installing resolv gem..."
  system("gem install resolv -v 0.2.3") or raise "gem install resolv failed" # NOSONAR
  puts "resolv gem installed successfully"
end
