name "remove-old-gems"

license :project_license
skip_transitive_dependency_licensing true

build do
  block "Removing old versions of rexml < 3.4.2" do
    gembin = "#{install_dir}/embedded/bin/gem"

    next unless File.exist?(gembin)

    puts "Removing old versions of rexml < 3.4.2"
    env = with_standard_compiler_flags(with_embedded_path)

    # remove [-a] all rexml < 3.4.2 including [-x] executables and [-I] ignore dependencies
    command "#{gembin} uninstall rexml -v \"<3.4.2\" -a -x -I", env: env
  end
end
