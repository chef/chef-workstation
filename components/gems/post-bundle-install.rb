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

  Dir.chdir(File.expand_path(gempath)) do
    gemspec_file = "#{gem_name}.gemspec"
    gem_file_pattern = "#{gem_name}-*.gem"

    unless File.exist?(gemspec_file)
      raise "Error: Gemspec not found for #{gem_name} in #{gempath}"
    end

    puts "Building gem using #{gemspec_file} in #{gempath}..."
    unless system("gem build #{gemspec_file}")
      raise "Gem build failed for #{gem_name}. Check gemspec and dependencies."
    end

    puts "Looking for built gem matching #{gem_file_pattern}..."
    built_gem = Dir.glob(gem_file_pattern).first
    unless built_gem
      raise "Error: No built gem found for #{gem_name}. Check gem build output."
    end

    puts "Installing gem: #{built_gem}"
    install_command = "gem install #{built_gem} --conservative --minimal-deps --no-document"
    puts "Running: #{install_command}"

    unless system(install_command)
      raise "Gem install failed for #{built_gem}. Check the error output."
    end

    puts "Successfully installed #{built_gem}"
  end
end
