commands
  chef
    flow
      for quicktest
        .show-text I'm looking at you .e my_env_var! Where are you?

      for converge node1 enable nginx_site my_home_page
        .show-text nginx_site is in the nginx cookbook.
        .show-text I can't find the nginx cookbook locally, I'll download it now.
        .spinner Downloading... # TODO: .progress support
          .success after 1s Download complete
        .show-text Configuring nginx site 'my_home_page'
        .success after 2s Site setup complete!

      for converge node1 install package nginx --show-attributes
        .show-text The nginx cookbook supports the following attributes:
        .table Attribute|Description|Env Var
          dir|nginx install location|nginx_dir
          port|port to listen on|nginx_port
          gzip|'on' to enable gzip, 'off' to disable it|nginx_gzip
        .show-text .n
        .show-text You can set the environment variable shown in 'Env Var' for each attribute.
        .show-text This can be either preceding the command, or exported before hand:
        .show-text .t export nginx_port=8080
        .show-text .t nginx_gzip=on chef apply nginx
        .show-text .n
        .show-text You can also set these options on the command line in the form attr=VALUE:
        .show-text .t chef apply nginx port=8080 gzip=on


      for converge node1 install package nginx dir=/home/web user=web port=8080
        .success Found local nginx cookbook
        .show-text Resource will be applied using the following attributes:
        .show-text .n
        .table Attribute|Value|Source
          dir|/home/web|Argument
          user|web|Argument
          port|8080|Argument
        .show-text Use ctrl+c now if these are incorrect
        .show-text after 3s Proceeding with converge of TARGET
        .spinner [TARGET] Connecting...
          .show-text after 2s Connected, checking for existing chef installation
          .show-text after 0s Chef installed, applying your change.
          .success after 1s Your change has been applied!

      for converge node1 install package nginx
        .failure nginx cookbook not found locally
        .spinner Downloading nginx cookbook and its dependencies locally
          .success after 1s Download complete
        .spinner [TARGET] Connecting...
          .show-text after 2s [TARGET] Connected, checking for existing chef installation
          .show-text after 0s [TARGET] Chef installed, applying your change.
          .success after 1s TARGET has been converged!

      for converge node1 install package nginx --confirm
        .failure nginx cookbook not found locally
        .spinner Downloading nginx cookbook and its dependencies locally
          .success after 1s Download complete
        .show-text .n
        .show-text Resource will be applied using the following attributes:
        .show-text .n
        .table Attribute|Value|Source
          dir|.e nginx_dir|env: $nginx_dir
          user|.e nginx_user|env: $nginx_user
          port|Default Value|80
        .show-text Use ctrl+c now if these are incorrect
        .show-text after 3s Proceeding with converge of TARGET
        .spinner [TARGET] Connecting...
          .show-text after 2s Connected, checking for existing chef installation
          .show-text after 0s Chef installed, applying your change.
          .success after 1s Your change has been applied!

# Different syntactic approaches that do the same thing
      for converge node1 package install nginx
        .use converge node1 install package nginx
      for converge node1 package nginx install
        .use converge node1 install package nginx
      for converge node1 package[nginx] action:install
        .use converge node1 install package nginx

    definition
      COMMAND
        the command to run, such as 'converge'
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
      --show-*attributes
        For converge, this will only show the configurable attributes
        supported by the resource specified; it does not apply any changes.
      --confirm
        When this flag is present, final configuration will be presented
        to you before applying to the remote node, and an opportunity to
        stop the run will be given.
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
