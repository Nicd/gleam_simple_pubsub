import gleam/erlang/process
import gleam/list
import gleeunit
import gleeunit/should
import processgroups as pg
import simple_pubsub as ps

pub fn main() {
  let _ = pg.start_link()
  gleeunit.main()
}

pub type PubSubMessage {
  PubSubMessage
}

pub fn send_receive_test() {
  // setup
  let pubsub = ps.new_pubsub()
  let ps_subject = ps.subscribe(pubsub, process.self())

  // act
  ps.broadcast(pubsub, PubSubMessage)
  let recv_msg = ps.receive(ps_subject, 100)

  // test
  should.equal(recv_msg, Ok(PubSubMessage))
}

pub fn send_receive_multiple_test() {
  // setup
  let pubsub = ps.new_pubsub()
  let #(monitor, _) = ps.monitor(pubsub)
  let task_subjects =
    list.range(1, 10)
    |> list.map(fn(_) {
      let parent = process.new_subject()
      // start the task
      process.spawn(fn() {
        let assert Ok(msg) =
          ps.subscribe(pubsub, process.self())
          |> ps.receive(100)
        process.send(parent, msg)
      })
      // wait for it to register
      let _ =
        pg.selecting_process_group_monitor(
          process.new_selector(),
          monitor,
          fn(a) { a.pids },
        )
        |> process.selector_receive(100)
      // return the task subject to receive on
      parent
    })

  // act
  ps.broadcast(pubsub, PubSubMessage)
  let res =
    task_subjects
    |> list.map(fn(t) {
      let assert Ok(msg) = process.receive(t, 100)
      msg
    })

  // test
  should.equal(
    res,
    list.range(1, 10)
      |> list.map(fn(_) { PubSubMessage }),
  )
}
