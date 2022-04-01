# Print all the gems and other paths installed in the Chef Workstation omnibus as a JSON hash. This is
# stored in the root of the Chef Workstation install next to the `ruby-env.json`.

def omnibus_expand_path(*paths)
  dir = File.expand_path(File.join(paths))
  dir = "" unless dir && File.directory?(dir)
  dir
end

def expected_omnibus_root
  File.expand_path(File.join(Gem.ruby, "..", "..", ".."))
end

def omnibus_root
  omnibus_expand_path(expected_omnibus_root)
end

def omnibus_bin_dir
  omnibus_expand_path(omnibus_root, "bin")
end

def omnibus_embedded_bin_dir
  omnibus_expand_path(omnibus_root, "embedded", "bin")
end

def git_bin_dir
  File.expand_path(File.join(omnibus_root, "gitbin"))
end

def git_windows_bin_dir
  File.expand_path(File.join(omnibus_root, "embedded", "git", "usr", "bin"))
end

def omnibus_env
  user_bin_dir = File.expand_path(File.join(Gem.user_dir, "bin"))
  path = [ omnibus_bin_dir, user_bin_dir, omnibus_embedded_bin_dir, ENV["PATH"].split(File::PATH_SEPARATOR) ]
  path << git_bin_dir if Dir.exist?(git_bin_dir)
  path << git_windows_bin_dir if Dir.exist?(git_windows_bin_dir)
  {
    "PATH" => path.flatten.uniq.join(File::PATH_SEPARATOR),
    "GEM_ROOT" => Gem.default_dir,
    "GEM_HOME" => Gem.user_dir,
    "GEM_PATH" => Gem.path.join(File::PATH_SEPARATOR),
  }
end

def ruby_info
  {}.tap do |ruby|
    ruby["Executable"] = Gem.ruby
    ruby["Version"] = RUBY_VERSION
    ruby["RubyGems"] = {}.tap do |rubygems|
      rubygems["RubyGems Version"] = Gem::VERSION
      rubygems["RubyGems Platforms"] = Gem.platforms.map(&:to_s)
      #             rubygems["Gem Environment"] = gem_environment
    end
  end
end

def omnibus_install?
  File.exist?(expected_omnibus_root) && File.exist?(File.join(expected_omnibus_root, "version-manifest.json"))
end

def read_version_manifest_json
  File.read(File.join(omnibus_root, "version-manifest.json"))
end

def manifest_hash
  JSON.parse(read_version_manifest_json)
end

def read_gem_version_manifest_json
  File.read(File.join(omnibus_root, "gem-version-manifest.json"))
end

def gem_manifest_hash
  JSON.parse(read_gem_version_manifest_json)
end

def chef_ws_build_version
  if omnibus_install?
    manifest_hash["build_version"]
  else
    ""
  end
end

def chef_cli_version
  if omnibus_install?
    gem_manifest_hash["chef-cli"][0]
  else
    ""
  end
end

require "json"

info = {}
info["omnibus path"] = omnibus_env
info["omnibus root"] = omnibus_root
info["ruby info"] = ruby_info
info["build_version"] = chef_ws_build_version
info["chef-cli"] = chef_cli_version

j = JSON.pretty_generate(info)

environment_file = ARGV[0]
File.open(environment_file, "w") do |f|
  f.write(j)
end
