name "nodejs-binary-cleanup.rb"
description "Clean up nodejs from the build so we don't ship it"
default_version "1.0.0"

license :project_license
skip_transitive_dependency_licensing true

build do
  delete File.join(install_dir, "embedded", "nodejs")
end
