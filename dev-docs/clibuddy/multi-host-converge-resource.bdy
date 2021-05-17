commands
  chef
    flow
      for converge host1.local,host2.local,host3.local package nginx
        .description Show multi-host converge, success case
        .parallel Converging requested targets
          .spinner [host1.local] Connecting...
            .show-text after 1.0s [host1.local] Connected.
            .show-text after 0.5s [host1.local] Verifying Chef client installation
            .show-text after 0.5s [host1.local] Client already present on system.
            .show-text after 0.5s [host1.local] Converging package[nginx] on target...
            .success after 1.0s [host1.local] Successfully converged target!
          .spinner [host2.local] Connecting...
            .show-text after 0.8s [host2.local] Connected.
            .show-text after 0.5s [host2.local] Verifying Chef client installation
            .show-text after 0.5s [host2.local] Client already present on system.
            .show-text after 0.5s [host2.local] Converging package[nginx] on target...
            .success after 1.5s [host2.local] Successfully converged target!
          .spinner [host3.local] Connecting...
            .show-text after 0.8s [host3.local] Connected.
            .show-text after 0.5s [host3.local] Verifying Chef client installation.
            .show-text after 0.5s [host3.local] Downloading Chef client installer.
            .show-text after 0.5s [host3.local] Installing Chef client.
            .show-text after 3.0s [host3.local] Converging package[nginx] on target...
            .success after 1.0s [host3.local] Successfully converged target!
      for converge host[1-3].local package nginx
        .description Show multi-host converge using a range specifier
        .parallel Converging requested targets
          .spinner [host1.local] Connecting...
            .show-text after 1.0s [host1.local] Connected.
            .show-text after 0.5s [host1.local] Verifying Chef client installation
            .show-text after 0.5s [host1.local] Client already present on system.
            .show-text after 0.5s [host1.local] Converging package[nginx] on target...
            .success after 1.0s [host1.local] Successfully converged target!
          .spinner [host2.local] Connecting...
            .show-text after 0.8s [host2.local] Connected.
            .show-text after 0.5s [host2.local] Verifying Chef client installation
            .show-text after 0.5s [host2.local] Client already present on system.
            .show-text after 0.5s [host2.local] Converging package[nginx] on target...
            .success after 1.5s [host2.local] Successfully converged target!
          .spinner [host3.local] Connecting...
            .show-text after 0.8s [host3.local] Connected.
            .show-text after 0.5s [host3.local] Verifying Chef client installation.
            .show-text after 0.5s [host3.local] Downloading Chef client installer.
            .show-text after 0.5s [host3.local] Installing Chef client.
            .show-text after 3.0s [host3.local] Converging package[nginx] on target...
            .success after 1.0s [host3.local] Successfully converged target!
      for converge host1.local,host[2-3].local package nginx
        .description Show multi-host converge using a range specifier and comma-separated list
        .parallel Converging requested targets
          .spinner [host1.local] Connecting...
            .show-text after 1.0s [host1.local] Connected.
            .show-text after 0.5s [host1.local] Verifying Chef client installation
            .show-text after 0.5s [host1.local] Client already present on system.
            .show-text after 0.5s [host1.local] Converging package[nginx] on target...
            .success after 1.0s [host1.local] Successfully converged target!
          .spinner [host2.local] Connecting...
            .show-text after 0.8s [host2.local] Connected.
            .show-text after 0.5s [host2.local] Verifying Chef client installation
            .show-text after 0.5s [host2.local] Client already present on system.
            .show-text after 0.5s [host2.local] Converging package[nginx] on target...
            .success after 1.5s [host2.local] Successfully converged target!
          .spinner [host3.local] Connecting...
            .show-text after 0.8s [host3.local] Connected.
            .show-text after 0.5s [host3.local] Verifying Chef client installation.
            .show-text after 0.5s [host3.local] Downloading Chef client installer.
            .show-text after 0.5s [host3.local] Installing Chef client.
            .show-text after 3.0s [host3.local] Converging package[nginx] on target...
            .success after 1.0s [host3.local] Successfully converged target!
      for converge host1,hosta2 user xiao
        .description Show multi-host converge, single failure
        .parallel Converging requested targets
          .spinner [hosta2] Connecting...
            .failure after 2.0s [host2a] .redConnection failed: getaddrinfo: Name or service not known
          .spinner [host1] Connecting...
            .show-text after 1.0s [host1] Connected.
            .show-text after 0.5s [host1] Verifying Chef client installation
            .show-text after 0.5s [host1] Client already present on system.
            .show-text after 0.5s [host1] Converging user[xiao] on target...
            .success after 1.0s [host1] Successfully converged target!
        .show-error CHEFCON001
      for converge host1,hosta2 usera jame
        .description Show multi-host converge, all failed
        .parallel Converging requested targets
          .spinner [host1] Connecting...
            .show-text after 1.0s [host1] Connected.
            .show-text after 0.5s [host1] Verifying Chef client installation
            .show-text after 0.5s [host1] Client already present on system.
            .show-text after 0.5s [host1] Converging usera[jame] on target...
            .failure after 1.0s [host1] .red'usera' is not a valid Chef resource
          .spinner [hosta2] Connecting...
            .failure after 2.0s [host2a] .redConnection failed: getaddrinfo: Name or service not known
        .show-error CHEFCON001
    definition
      SUBCOMMAND
        the command to run
      ACTION
        the action to perform, such as 'converge'
      TARGET
        the host, IP or host group to apply changes to, or comma-separated
        list of hosts.
      RECIPE
        the cookbook or cookbook+recipe to apply to the remote target(s)j
      RESOURCE
        the type of resource to invoke
      RS_NAME
       the name property to supply to the resource
      [PROPERTIES]
        one or more cookbook properties in the form name=value,
        separated by spaces. This must be the final argument.
      --*help
        shows usage details for this command
      --show-full-errors
        if one or more targets fails to converge, show the full error message
        text instead of writing to file.
     --*confirm
        Used with 'converge'. When this flag is present, final configuration
        will be presented to you before applying to the remote node, and an
        opportunity to stop the run will be given before any change is applied.
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


  CHEFCON001
    One or more nodes has failed to converge.  For error details,
    see ~/.chef-workstation/logs/converge_failures.log

  CHEFNET001
    .n
    A network error occurred:
    .n
    .tgetaddrinfo: Name or service not known
    .n
    Please verify the host name or address is correct and that the host is
    reachable before trying again.
    .n
    If you are not able to resolve this issue, please contact Chef support
    at workstation@chef.io
