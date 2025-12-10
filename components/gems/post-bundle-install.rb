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

# Handle default gem conflicts with bundled gems
# CVE-2025-24294: resolv 0.2.1 has a security vulnerability
default_gem_list = {
  resolv: "0.2.1",
}

default_gem_list.each do |gem_name, version|
  puts "Checking #{gem_name} gem installation..."
  gem_info = `gem info #{gem_name}`

  # Check if the old default version exists
  if gem_info.include?("default):") && gem_info.match?(/#{gem_name} \([0-9., ]*#{version}[0-9., ]*\)/)
    puts "Found default #{gem_name} (#{version}), removing gemspec and upgrading..."

    # Windows: Ruby runs from omnibus-toolchain during build, need to check all gem paths
    # Linux/macOS: Extract path directly from gem info output
    if RUBY_PLATFORM =~ /mswin|mingw|windows/
      Gem.path.each do |gem_path|
        gemspec_path = File.join(gem_path, "specifications", "default", "#{gem_name}-#{version}.gemspec")

        if File.exist?(gemspec_path)
          puts "Removing default #{gem_name} gemspec: #{gemspec_path}"
          File.delete(gemspec_path)
        end
      end
    else
      # Extract the default gem path from gem info output
      default_path = gem_info.match(/default\): (.+)$/)[1]

      if default_path
        gemspec_path = File.join(default_path.strip, "specifications", "default", "#{gem_name}-#{version}.gemspec")

        if File.exist?(gemspec_path)
          puts "Removing default #{gem_name} gemspec: #{gemspec_path}"
          File.delete(gemspec_path)
        end
      end
    end

    # Install the newer version to the embedded gem path
    puts "Installing #{gem_name} gem to #{gem_home}..."
    system("gem install #{gem_name} -v 0.2.3 --install-dir #{gem_home} --no-document") or raise "gem install #{gem_name} failed" # NOSONAR
    puts "#{gem_name} gem installed successfully"
  else
    puts "#{gem_name} (#{version}) not found as default gem, skipping"
  end
end
