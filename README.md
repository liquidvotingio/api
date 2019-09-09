# Liquid Voting as a Service (POC)

Proof of concept for a liquid voting service that can be easily plugged into proposal-making platforms of different kinds.

Part fun itch scratcher, part résumé-driven development.

Clone the repo and:

```
mix deps.get
mix ecto.setup
mix phx.server
open http://localhost:4000/graphiql
```

Just got the first queries working:

```
query {
  participants {
    id
    name
  }
}

query {
  participant(id: 1) {
    id
    name
  }
}
```

TODO:

* Graphql schemas resolvers for querying/mutating votes and delegations, and for subscribing to voting results
* get some test coverage
* dockerize
* kuberize
* CI/CD
* logging
* monitoring
* perf tests
* JS widget
* next services: authentication, notifications
