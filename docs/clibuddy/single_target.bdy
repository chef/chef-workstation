# SHACK-80 - document syntax for performing single resource, single target converge. Some of these
# are discussion examples that we will not implement.
commands
  converge
    flow
      for -h
        .show-usage
# When we take all connection defaults from ~/.ssh/config (or later, inventory)
# Also, showing that we only install chef-client on the first run - it stays installed
# for speed purposes later
      for node1.ec2.chef.co package vim
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected - using config specified in ~/.ssh/config
        .spinner [TARGET] Performing first time setup...
          .success after 1s [TARGET] First time setup completed successfully!
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!
# When we specify connection information on the command line in 2 possible ways
      for node1.ec2.chef.co package vim --user myuser --ssh-key .ssh/id_rsa --port 2222
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!
      for myuser@node1.ec2.chef.co:2222 package vim
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!
# Train wants us to specify `ssh://` or `winrm://` - do we want our users doing the same?
# We could assume ssh is the default and anything else they must specify
      for winrm://myuser@node1-windows.ec2.chef.co:2222 package notepad++
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!
# Could specify with a transport flag instead of command line
      for myuser@node1-windows.ec2.chef.co:2222 package notepad++ --transport winrm
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!
# Detailed output should be sent to a file unless they specify --verbose
# and then we will display detailed info (like debug logging) on stdout
      for host-detailed package vim
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .success after 1s [TARGET] RESOURCE[RS_NAME] applied successfully!
        .show-text Detailed results stored in ~/.chef/shak/TARGET-1519687415
# Some error scenarios
      for error1.ec2.chef.co package vim
        .spinner [TARGET] Connecting...
          .failure after 2s [HOST] Could not connect
        .show-error APPLY0001
# Do we have to connect to the remote machine, install Chef and run a remote resource
# to determine that it does not exist?
      for error2.ec2.chef.co package vim
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .failure after 2s No resource named RESOURCE
        .show-error APPLY0002
# Full chef client output should be in another file
      for error3.ec2.chef.co package vim
        .spinner [TARGET] Connecting...
          .success after 1s [TARGET] Connected
        .spinner [TARGET] Applying RESOURCE[RS_NAME]
          .failure after 2s Failed trying to apply RESOURCE[RS_NAME]
        .show-error APPLY0003
    definition
      TARGET
        the host, IP or host group to apply changes to
      RESOURCE
        the type of resource to invoke
      RS_NAME
       the name property to supply to the resource
      --*help
        shows usage details for this command
      --user NAME
        user to authenticate as
      --ssh-key PATH_TO_KEY
        path to the ssh key file to use for for authentication
      --port PORT
        remote port to connect to
      --trasport TRANSPORT
        transport type to use, can be 'ssh' or 'winrm'
    usage
      short
        Apply RESOURCE to TARGET
      full
        Run the named resource on the target.
messages
  APPLY0001
    .red Could not connect to desired target

    The target 'TARGET' could not be reached. We could have
    details here saying why it could not be reached - bad
    connection, tried both ssh and winrm, timed out trying
    a command, etc.
  APPLY0002
    .red Could not find a resource named RESOURCE
  APPLY0003
    .red Failed to apply resource RESOURCE[RS_NAME]

    Detailed output can be found in /foo/bar/detailed
