# Software Walk thru for OpenC2 Commands

## Example 1 - Sunny Day Query SBOM List
Message received:
``` json
{"action": "query",
 "target": {
 	"sbom": {
      "list": ""
     }
  }
}
```

### Mqtt
* Tortoise handles MQTT
* connection already established
   - add where config (eg which broker) comes from
   - add where channels etc configured

### Mqtt.Handler.handle_message
* Mqtt.Handler is a behaviour of Tortoise for handling mqtt.
* When a message arrives on the ???oc2/cmd/device/t01??? topic,
* Mqtt.Handler.handle_message calls OC2.Command.new 
which will eventually return with a struct


1. sends message to OC2.Command.new which initializes a struct
2. which is passed to Oc2.Command.do_cmd which does the command passes the result to
3. Mqtt.Command.return_result

### Oc2.Command.new
* Oc2.Command.new is given the message from mqtt handler,
* decodes the json, and 
* calls Oc2.CheckOc2.new with the message,
* Oc2.CheckOc2.new returns a new instance of the Oc2.Command struct


initializes the command struct (Oc2.CheckOc2.new),
validates the command (Oc2.CheckOc2.check_cmd), 
and returns command struct.

### Oc2.CheckOc2.new
* Oc2.CheckOc2.new is given the decoded message from Oc2.Command.new,
* creates a new instance of the Oc2.Command struct
* adds the entire command to the cmd element in the struct
* returns the struct to Oc2.Command.new

### Oc2.Command.new
* Oc2.Command.new receives the struct from Oc2.CheckOc2.new
* calls Oc2.CheckOc2.check_cmd with the struct
* expecting the struct back

### Oc2.CheckOc2.check_cmd
* Oc2.CheckOc2.check_cmd receives the struct from Oc2.Command.new
* check_cmd sends the struct to check_top
   - validating "action" is present
   - validating "target" is present
   - "action:query" is in @actions
   - validating "target:sbom" is in @targets 
* check_cmd sends the struct to check_action
   - validating action:query ie that query is in @actions
   - adds action:query to command struct
* check_cmd sends the struct to get_target
   - uses good_target? to validate {"sbom": {"list": []} is a map with only one key
   - Breaks "target": {"sbom": {"list": []} into
     - target : sbom
     - target_specifier: {"list": []}
   - add target and target_specifier to struct
* check_cmd sends the struct to check_target
   - validates sbom in @targets
   - validates query:sbom in @action_target_pairs
* check_cmd sends the struct to check_id
   - no id so passes same struct back
* check_cmd sends the struct to check_args
   - no response_req arg so default to complete
   - adds complete to struct
* check_cmd sends the struct to log_cmd
   - logs struct
* check_cmd returns the struct to Oc2.Command.new

### Oc2.Command.new


### Oc2.Command.do_cmd
is given the command struct, validaes the command, executes the command, and returns result

### lib/mqtt/command.ex
Mqtt.Command.return_result encodes and publishes the response to sFractal/response topic.

## Example 2