name "nodejs-binary-cleanup.rb"
description "Clean up nodejs from the build so we don't ship it"
default_version "1.0.0"

license :project_license
skip_transitive_dependency_licensing true

build do
  # TODO delete this component, we are not using this component but I don't want to change
  #      chef-workstation.rg and trigger a complete rebuild of allthethings.
end
