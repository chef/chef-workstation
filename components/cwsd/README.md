## Build it:

```
cd $GOPATH/github.com/chef`l
```

Clone chef-workstation here, or symlink it in from your regular location.

```
git checkout mp/poc/cwsd
cd components/cwsd
go build
```

## Run It
Make sure that you have a valid ~/.chef-workstation/config.toml, and make sure
you've backed it up - if you PUT any config values, it will overwrite it and lose comments.

```
./cwsd
```

### GET a config value

```
curl http://localhost:9729/config/telemtry.enable
```

### PUT a config value

```
 curl -X "PUT" http://localhost:9729/config/telemetry.enable -H "Content-Type: application/json" -d '{ "value": true }'
```

You can set `value` to an appropriate value for the config key you're setting.

NOTE: Anything other than a simple value (base type bool/string/float) or an array of simple values
will probably behave unexpectedly.

NOTE 2: PUTting a value will cause `cwsd` to rewrite your `~/.chef-workstation/config.toml`, replacing
contents and removing any comments present.   Fixing this is a TODO.


## Thoughts

* This was hhacked out pretty quickly. If we move forward with development, we'll want to check in
  with #goguild and follow project structure recommended - or at least the bits that make sense given
  that we're not an a2 component.
* Several things were done expediently, but not very cleanly.  We'll want to fix those up too...





