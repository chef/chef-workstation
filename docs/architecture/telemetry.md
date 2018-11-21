# Telemetry

## Overview

In order to provide consistent capture of telemetry data for the components of Chef Workstation,
we will extend Chef Workstation App to provide a simple telemetry API over REST.


## Constraints

* user opt-in preferences must be respected in all cases.
* transient opt-out via environment variable `CHEF_TELEMETRY_OPT_OUT` must be respected

The telemetry service in CWA will listen on configurable local port 21000.  Clients and server must respect the
configured port,


## Service

When a payload is received by CWA Telemetry Service via a POST to the `/telemetry` endpoint,
the service will start asynchronous preparation of the final payload and return an HTTP 201 immediately.
The caller will not receive success/failure notification of the payload's final upstream disposition.

If the payload field `TELEMETRY_OPT_OUT` contains any value other than nil, or the config key `telemetry.enabled` is `false`,
the telemetry payload will be dropped without further processing. This lets us limit the opt-out checks to live only
in the service, without the clients having to make decisions based on its presence.

The outbound telemetry payload is a JSON object that complies with
the [es-telemetry-pipeline event schema](https://github.com/chef/es-telemetry-pipeline/blob/master/schema/event.schema.json).

Most of those fields are self-explanatory, but some things are worth calling out:

* `instance_id` will be populated from `$CONFIG_DIR/telemetry/instance_id`
* `session_id` will be unique per inbound payload. If the inbound payload contains multiple
  events, each event will be submitted with the same session id.
* `timestamp` will be generated when the event is submitted to the the CWA telemetry service  and
  will be the same for each event in the session.

Once the final payload is generated, it will be sent to `telemetry.chef.io` or
`telemetry-acceptance.chef.io` if the service is run in developement mode.

Failures will be logged.

## Sequence Diagram


```
       ,-.
       `-'
       /|\
        |             ,--------.             ,---.          ,-----------------.
       / \            |CLI Tool|             |CWA|          |telemetry.chef.io|
      Human           `---+----'             `-+-'          `--------+--------'
        |    execute      |                    |                     |
        |---------------->|                    |                     |
        |                 |                    |                     |
        |                 |  POST /telemetry  ,-.                    |
        |                 | ----------------->|X|                    |
        |                 |                   |X|                    |
        |                 | http response 201 |X|                    |
        |                 | <- - - - - - - - -|X|                    |
        |                 |                   `-'                    |
        |                 |                    ----.                 |
        |                 |                        | prepare envelope|
        |                 |                    <---'                 |
        |                 |                    |                     |
        |                 |                    |   POST payload     ,-.
        |                 |                    |------------------> |X|
        |                 |                    |                    |X|
        |                 |                    |  JSON response     |X|
        |                 |                    |<------------------ |X|
      Human           ,---+----.             ,-+-.          ,-------`-'-------.
       ,-.            |CLI Tool|             |CWA|          |telemetry.chef.io|
       `-'            `--------'             `---'          `-----------------'
       /|\
        |
       / \
```

## REST API

### POST /telemetry

A collection of one or more events is submitted to this endpoint as JSON.  Applications should wait until
all events are complete before submitting to ensure that all events are captured under the same session identifier.

#### Sample Payload
```
{
  "component": "chef-run",
  "TELEMETRY_OPT_OUT": "",  # the value of the TELEMETRY_OPT_OUT environment variable at run time
  "entries": [
    {
      "event": "run",
      "properties": {
        "event_data": {
          "arguments": [
            "redacted"
          ],
          "duration": 13.99565049802186
        }
      }
    },
    {
      "event": "action",
      "properties": {
        "event_data": {
          "action": "ConvergeTarget",
          "target": {
            "platform": {
              "name": "linux",
              "version": "14.04",
              "architecture": "x86_64"
            },
            "hostname_sha1": "28d6ba9011aaec66788b426505afe09b32cfe169",
            "transport_type": "ssh"
          },
          "duration": 8.67385252402164
        }
      }
    },
    {
      "event": "action",
      "properties": {
        "event_data": {
          "action": "InstallChef::Linux",
          "target": {
            "platform": {
              "name": "linux",
              "version": "14.04",
              "architecture": "x86_64"
            },
            "hostname_sha1": "28d6ba9011aaec66788b426505afe09b32cfe169",
            "transport_type": "ssh"
          },
          "duration": 0.3116972380084917
        }
      }
    },
    {
      "event": "action",
      "properties": {
        "event_data": {
          "action": "GenerateLocalPolicy",
          "duration": 2.3167553970124573
        }
      }
    },
    {
      "event": "action",
      "properties": {
        "event_data": {
          "action": "GenerateCookbookFromResource",
          "duration": 0.00044321699533611536
        }
      }
    }
  ]
}
```

Source: telemetry-seq.puml, generated via `java -jar plantuml.jar -txt telemetry-seq.puml. plantuml can be downloaded from http://plantuml.com.

## Client

A client interface is already defined in ``ChefApply::Telemeter``.  This will need modification to POST to an endpoint instead of
writing payloads to YML files. The JSON format above is slightly different than what it's currently sending - fields like `installation_id`, `run_timestamp`,
`host_platform` have been removed.

Client will be responsible for POSTing the complete session to the `telemetry` endpoint. The client will handle any failures by logging errors as they occur;
but it will not report failures back to the operator.

This will need to be shared across Workstation components. I recommend that we extract this into a new gem `chef-ws-core` that
houses cross-tool concerns.

## Future

Exposing a local REST API interface opens the door to future user experience enhancements:

* background `chef-run` for large numbers of host with reporting to tray and/or CLI
* cross-editor code completion support for Chef artifacts across editors via Language Server Protocol implementation

## Alternatives Considered

### Share chef-run's batching/sending code across components

#### Advantages

* Minimal effort
* Since multiple tools would be processing payloads, any time a CW tool was invoked
  it would be another chance to clear out any backlog of telemetry events from previous runs.

#### Disadvantages

* Heavy solution where each component (via the shared lib) will be starting its own background sender thread to send outbound telemetry requests
* Local firewall rules would need to be configured for each component of CW.
* If we need to expand support to additional client languages, the re-implementation of the behavior
  is more involved than porting a client REST wrapper to another language.

### Standalone Daemon (Go)

#### Advantages

* Clean separation of domains along process boundaries
* potentially begins to move away from ruby depenency
* We can ensure it is always running via system service management, vs CWA which the user
  can terminate at any time from the tray/menu.

#### Disadvantages

* Expands language footprint, associated learning curve
* Another new component to be built and managed  with limited resources

