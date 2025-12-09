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
# Maps gem name to old version that needs to be replaced
default_gem_list = {
  resolv: "0.2.1",
}

default_gem_list.each do |gem_name, old_version|
  puts "Checking #{gem_name} gem installation..."
  gem_info = `gem info #{gem_name}`

  # Check if the old default version exists
  if gem_info.include?("Installed at (default):") && gem_info.include?("#{gem_name} (#{old_version})")
    puts "Found default #{gem_name} (#{old_version}), removing gemspec and upgrading..."
    
    # Windows-specific: check all gem paths due to multiple Ruby locations
    # Other platforms: extract from gem info output (existing working logic)
    if RUBY_PLATFORM =~ /mswin|mingw|windows/
      # Remove gemspec from all gem paths
      Gem.path.each do |gem_path|
        gemspec_path = File.join(gem_path, "specifications", "default", "#{gem_name}-#{old_version}.gemspec")
        
        if File.exist?(gemspec_path)
          puts "Removing: #{gemspec_path}"
          File.delete(gemspec_path)
        end
      end
    else
      # Linux/macOS: extract default path from gem info output
      gem_info.lines.each do |line|
        if line.include?("Installed at (default):")
          default_path = line.split("Installed at (default):").last&.strip
          if default_path
            gemspec_path = File.join(default_path, "specifications", "default", "#{gem_name}-#{old_version}.gemspec")
            
            if File.exist?(gemspec_path)
              puts "Removing: #{gemspec_path}"
              File.delete(gemspec_path)
            end
          end
          break
        end
      end
    end

    # Install the newer version - specify version for resolv, latest for others
    puts "Installing #{gem_name} gem..."
    install_cmd = gem_name == :resolv ? "gem install #{gem_name} -v 0.2.3" : "gem install #{gem_name}"
    system(install_cmd) or raise "gem install #{gem_name} failed" # NOSONAR
    puts "#{gem_name} gem installed successfully"
  else
    puts "#{gem_name} (#{old_version}) not found as default gem, skipping"
  end
end
