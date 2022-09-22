#!/bin/bash -e
# regenerate rails secret key and mysql password

. /etc/default/inithooks

APPNAME=$(cat /etc/turnkey_version  | perl -pe 's/^turnkey-//; s/-[^-]+(-[^-]+){2}$//')
[ "$APPNAME" == "rails" ] && APPNAME=railsapp ## namespace conflict
WEBROOT=/var/www/$APPNAME

# regen master key and credentials files (introduced in rails 5.2)
CRED_FILE=$WEBROOT/config/credentials.yml.enc
KEY_FILE=$WEBROOT/config/master.key
if [[ -f "$CRED_FILE" && -f "$KEY_FILE" ]]; then
    # regen secret_key_base and master.key without overwriting existing values
    cd $WEBROOT
    rails r $INITHOOKS_PATH/bin/regen_rails_encrypted_secret.rb
    chown www-data:www-data $CRED_FILE $KEY_FILE
elif [[ -f "$CRED_FILE" ]]; then
    # master.key is missing
    # backup existing credsfile and generate new key and credentials
    stamp=$(date +%s)
    echo "WARNING: Backing up existing $CRED_FILE & $KEY_FILE (copied with .$stamp.bak extension)." >&2
    echo "         If you have edited these, then you will probably need to recover these files." >&2
    mv $CRED_FILE $CRED_FILE.$stamp.bak

    # set editor as echo - hack to regen default files non-interactively
    cd $WEBROOT
    EDITOR=echo rails credentials:edit
    chown www-data:www-data $CRED_FILE $KEY_FILE
fi

# rails 4.1
CONF=$WEBROOT/config/secrets.yml
[ -e $CONF ] && sed -i "s|secret_key_base:.*|secret_key_base: '$(mcookie)$(mcookie)$(mcookie)$(mcookie)'|" $CONF

# rails 4.0
CONF=$WEBROOT/config/initializers/secret_token.rb
[ -e $CONF ] && sed -i "s|Application.config.secret_key_base\\s*=.*|Application.config.secret_key_base = '$(mcookie)$(mcookie)$(mcookie)$(mcookie)'|" $CONF

# rails 3.2
CONF=$WEBROOT/config/initializers/secret_token.rb
[ -e $CONF ] && sed -i "s|Application.config.secret_token\\s*=.*|Application.config.secret_token = '$(mcookie)$(mcookie)$(mcookie)$(mcookie)'|" $CONF

# rails 2.3
CONF=$WEBROOT/config/initializers/session_store.rb
[ -e $CONF ] && sed -i "s|:secret\\s*=>.*|:secret => \'$(mcookie)$(mcookie)\'|" $CONF

# rails 2.2
CONF=$WEBROOT/config/site.yml
[ -e $CONF ] && sed -i "s|^salt:.*|salt: \"$(mcookie)\"|" $CONF

# regen mysql password
PASSWORD=$(mcookie)
CONF=$WEBROOT/config/database.yml
sed -i "s|password:.*|password: $PASSWORD|g" $CONF
$INITHOOKS_PATH/bin/mysqlconf.py --user=$APPNAME --pass="$PASSWORD"

# remove innodb logfiles (workarounds really weird bug)
rm -f /var/lib/mysql/ib_logfile*

# restart passenger
touch $WEBROOT/tmp/restart.txt
