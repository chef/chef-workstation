commands
  chef
    flow
      for config -h
        .show-usage
      for config show
        .show-message CONFIG001
      for config show --config /some/path
        .show-message CONFIG002
    definition
      --*help
        shows usage details for this command
      --*config PATH
        user to authenticate as
    usage
      short
        Dump out loaded config
      full
        Load configuration, either from default location or
        specified location, then echo its contents to the screen.
        Because configuration can be specified in multiple
        formats we currently echo it using ruby hash syntax.
messages
  CONFIG001
    .greenConfig loaded from default path ~/.chef-workstation/config.toml .n

    {
      telemetry: {
        dev: true
      }
    }
  CONFIG002
    .greenConfig loaded from PATH .n

    {
      telemetry: {
        dev: true
      }
    }
