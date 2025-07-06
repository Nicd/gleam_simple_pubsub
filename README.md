# Simple PubSub for gleam

Simple PubSub for gleam, based on
[process groups](https://hex.pm/packages/processgroups).

[![Package Version](https://img.shields.io/hexpm/v/simple_pubsub)](https://hex.pm/packages/simple_pubsub)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/simple_pubsub/)

## Usage

Add this library to your Gleam project

```sh
gleam add simple_pubsub
```

And use it in your project

## Example

```gleam
import simple_pubsub as ps
import processgroups
import gleam/erlang/process

// Messages we want to send over the PubSub
type PubSubMessage{
    PubSubMessage
}

pub fn main() {
    // start process groups, needed for pubsub
    processgroups.start_link()

    // create a pubsub
    let pubsub = ps.new_pubsub()

    // subscribe, normally you would subscribe another process than this one
    let subscription = ps.subscribe(pubsub, process.self())

    // broadcast a message
    ps.broadcast(pubsub, PubSubMessage)

    // receive the message
    let assert Ok(PubSubMessage) = ps.receive(subscription, 100)
}
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
