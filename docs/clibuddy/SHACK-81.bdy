commands
  chef
    flow
      for show package
        .description Show the commonly used attributes for the resource given.
        .show-text The package resource supports the following attributes:
        .table Attribute|Description|Env Var
          action|action to perform|package_action
          version|package version to install|package_version
        .show-text .n

      for show package --extended-help
        .description Show additional helpful hints for 'show package'.
        .use show package
        .show-text You can set these options on the command line in the
        .show-text form attr=VALUE after other options/arguments:
        .show-text .t CMD converge /TARGET package nginx version=1.0
        .show-text .n
        .show-text You can set the environment variable shown in 'Env Var' for each attribute.
        .show-text This can be either preceding the command:
        .show-text .t version=1.0 CMD converge /TARGET package nginx
        .show-text .n
        .show-text Or it can be exported before invoking:
        .show-text .t export version=1.0
        .show-text .t CMD converge /TARGET package nginx
        .show-text .n

      for converge * package nginx
        .description Single resource, default action, multi-line progress
        .show-text I will converge TARGET with: .magenta RESOURCE[RS_NAME] action: install
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected - using config specified in ~/.ssh/config
        .spinner [TARGET] Performing first time setup...
          .success after 1s [TARGET] First time setup completed successfully!
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!

      for converge * package * action=remove
        .description Single resource, non-default action, single-line progress
        .show-text I will converge TARGET with: .magenta RESOURCE[RS_NAME] action: remove
        .spinner [TARGET] Connecting...
          .show-text after 1s [TARGET] Connected - using config specified in ~/.ssh/config
          .show-text after 0.5s [TARGET] Performing first time setup
          .show-text after 1s [TARGET] First time setup completed successfully!
          .show-text after .5s [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!

      for converge * package * action=remove version=9.2
        .description Custom action and additional attribute
        .use converge * package * action=remove

      for converge * with package nginx using version=9.2,action=install
        .description  Optional 'with' and 'using' keywords and action+attributes
        .use converge TARGET package nginx

      for converge * with package nginx version=9.2
        .use converge * package nginx
        .description Both 'with' and 'using' are optional; this example includes only 'with'.

      for converge * package nginx using version=9.2
        .use converge * package nginx
        .description Both 'with' and 'using' are optional; this example includes only 'using'.


      for converge * package nginx --confirm
        .description Show usage of confirm, and how env vars can be pulled in
        .show-text The following action and settings will be used when applying ACTION to TARGET:
        .show-text .n
        .table Attribute|Value|Source
          name | .magenta nginx | command line
          action | .magenta install | default action
          ignore_failure | .blue false | default
          user| .blue .e nginx_user | env: $nginx_user
        .wait-for-key Press CTRL+C to abort, and any other key to continue.
        .use converge * package nginx

    definition
      ACTION
        the action to perform, such as 'converge'
      TARGET
        the host, IP or host group to apply changes to
      RESOURCE
        the type of resource to invoke
      RS_NAME
       the name property to supply to the resource
      [ATTRIBUTES]
        one or more cookbook attributes in the form name=value,
        separated by spaces. This must be the final argument.
      --*help
        shows usage details for this command
      --*from-cookbook
        Tells chef what cookbook to find this resource definition in. if the
        cookbook is not available locally, chef will look for it on supermarket
      --*supermarket-url
        URL of a supermaket installation which provides cookbook downloads.
      --*no-download
        Do not download cookbooks if a resource can't be found.
      --*confirm
        Used with 'converge'. When this flag is present, final configuration
        will be presented to you before applying to the remote node, and an
        opportunity to stop the run will be given before any change is applied.
      --extended-help
        Used with 'show', provides examples of how resource attributes can be set.
    usage
      short
        Apply RESOURCE to TARGET
      full
        Run the named resource on the target.
        Note: clibuddy does not support subcommands.  This would be
        better managed as a subcommand within 'chef', because arguments
        would different significantly from other commands
messages
  APPLY0001
    .red Could not connect to desired target

    The target 'TARGET' could not be reached. We could have
    details here saying why it could not be reached - bad
    connection, tried both ssh and winrm, timed out trying
    a command, etc.
