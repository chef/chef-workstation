# get all the paths through ruby code

#     def omnibus_env
#       @omnibus_env ||=
#         begin
#           user_bin_dir = File.expand_path(File.join(Gem.user_dir, "bin"))
#           path = [ omnibus_bin_dir, user_bin_dir, omnibus_embedded_bin_dir, ENV["PATH"].split(File::PATH_SEPARATOR) ]
#           path << git_bin_dir if Dir.exist?(git_bin_dir)
#           path << git_windows_bin_dir if Dir.exist?(git_windows_bin_dir)
#           {
#             "PATH" => path.flatten.uniq.join(File::PATH_SEPARATOR),
#             "GEM_ROOT" => Gem.default_dir,
#             "GEM_HOME" => Gem.user_dir,
#             "GEM_PATH" => Gem.path.join(File::PATH_SEPARATOR),
#           }
#         end
#     end

require "json"
j = JSON.pretty_generate(all_paths)

manifest_file = "#{install_dir}/ruby-env.json"
File.open(manifest_file, "w") do |f|
  f.write(j)
end
