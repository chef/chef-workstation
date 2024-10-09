# Print all the gems installed in the Chef Workstation omnibus as a JSON hash. This is
# stored in the root of the Chef Workstation install next to the `version-manifest.json`.

all_gems = {}

Gem::Specification.load_defaults
Gem::Specification.each do |spec|
  all_gems[spec.name] ||= []
  all_gems[spec.name] << spec.version.to_s
end

require "json"
j = JSON.pretty_generate(all_gems)

gem_home = Gem.paths.home
manifest_file = "#{gem_home}/gem-version-manifest.json"
File.open(manifest_file, "w") do |f|
  f.write(j)
end
