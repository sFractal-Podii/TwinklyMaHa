## Publish message using Mosquitto broker to another device

To be able to publish a message to another device subscribed to a particular topic;
 
 1. Install the [mosquitto broker](https://www.vultr.com/docs/install-mosquitto-mqtt-broker-on-ubuntu-20-04-server/) in your machine, to be able to use the commands available 

 2. If publishing to another device, ensure the `TwinklyMaha` application is started on that device. This will be the device subscribed to the topic.

 Run:
 ```shell
 $ cd TwinklyMaha

 $ iex -S mix

 ```

 Before starting the application ensure you have the following exported in your system 

 ```
  export CLIENT_ID=:sfractal2020
  export MQTT_HOST="test.mosquitto.org"
  export MQTT_PORT=1883

 ```
You can as well add the exports in an `.env` file first then in the terminal run the following command 

 ```shell
 $ source .env
 ```
 3. The device with the mosquitto broker installed, will be responsible for publishing the message .

 Run the following command:

 ```shell
 mosquitto_pub -h "test.mosquitto.org" -t "sfractal/command" -m "hello"
 ```

-  `test.mosquitto.org` this is the public IP address provided by mosquitto broker . Its added to the application as `MQTT_HOST`

- `sfractal/command` is the topic that the broker is publishing to.

- `hello` is the message being published.

4. You should be able to see a logger info of the message `hello` displayed on the other device subcribed to the topic.

### NOTE: 

Since we are using a public IP address we cannot add password and username in the `mqtt` configuration.

In the following file , the password and username fields are commented out

```elixir
lib/mqtt.ex

{:ok, _} =
      Tortoise.Supervisor.start_child(
        Oc2Mqtt.Connection.Supervisor,
        client_id: client_id,
        handler: {Mqtt.Handler, [name: client_id]},
        server: server,
        # user_name: user_name,
        # password: password,
        subscriptions: [{"sfractal/command", 0}]
      )
```

### Turn Led on and off using mosquitto broker 

Once you have started your server on a different device or different terminal , run the command 

Turn led off

```shell
$ mosquitto_pub -h "test.mosquitto.org" -t "sfractal/command" -m '{"action": "set", "target": {"x-sfractal-blinky:led": "off"}, "args": {"response_requested": "complete"}}'

```

Turn led on

```shell
$ mosquitto_pub -h "test.mosquitto.org" -t "sfractal/command" -m '{"action": "set", "target": {"x-sfractal-blinky:led": "on"}, "args": {"response_requested": "complete"}}'

```

Turn led to a different color

```shell
$ mosquitto_pub -h "test.mosquitto.org" -t "sfractal/command" -m '{"action": "set", "target": {"x-sfractal-blinky:led": "rainbow"}, "args": {"response_requested": "complete"}}'

```

When you access `http://localhost:8080/twinkly` you should be able to see a twinky behaviour.
