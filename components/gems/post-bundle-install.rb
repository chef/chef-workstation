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
# This handles gems that ship as default with Ruby but need to be upgraded
default_gem_list = {
  resolv: { old_version: "0.2.1", install_version: "0.2.3" },
}

default_gem_list.each do |gem_name, config|
  old_version = config[:old_version]
  install_version = config[:install_version]
  
  puts "Checking #{gem_name} gem installation..."
  gem_info = `gem info #{gem_name}`

  # Check if the old default version exists
  if gem_info.include?("Installed at (default):") && gem_info.include?("#{gem_name} (#{old_version})")
    # Extract the default gem path
    default_path = nil
    gem_info.lines.each do |line|
      if line.include?("Installed at (default):")
        # Extract path after "Installed at (default):"
        default_path = line.split("Installed at (default):").last&.strip
        break
      end
    end

    if default_path && !default_path.empty?
      gemspec_path = File.join(default_path, "specifications", "default", "#{gem_name}-#{old_version}.gemspec")

      if File.exist?(gemspec_path)
        puts "Removing default #{gem_name} gemspec: #{gemspec_path}"
        begin
          File.delete(gemspec_path)
          puts "Successfully removed default #{gem_name} gemspec"
        rescue => e
          puts "Warning: Failed to remove gemspec: #{e.message}"
        end
      else
        puts "Default gemspec not found at: #{gemspec_path}"
      end
    else
      puts "Warning: Could not extract default gem path from gem info output"
    end

    # Install the gem with specific version if provided, otherwise install latest
    puts "Installing #{gem_name} gem..."
    install_cmd = install_version ? "gem install #{gem_name} -v #{install_version}" : "gem install #{gem_name}"
    system(install_cmd) or raise "gem install #{gem_name} failed" # NOSONAR
    puts "#{gem_name} gem installed successfully"
    
    # Verify installation
    verify_info = `gem info #{gem_name}`
    puts "Verification: #{gem_name} gem info after installation:"
    puts verify_info
  else
    puts "#{gem_name} (#{old_version}) not found as default gem, skipping"
  end
end
