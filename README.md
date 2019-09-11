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

Working queries:

```
query {
  participants {
    id
    name
    delegations_received {
      id
      delegator {
        id
        name
      }
      delegate {
        id
        name
      }
    }
  }
}

query {
  participant(id: 1) {
    id
    name
    delegations_received {
      id
      delegator {
        id
        name
      }
      delegate {
        id
        name
      }
    }
  }
}

query {
  proposals {
    id
    url
  }
}

query {
  proposal(id: 1) {
    id
    url
  }
}

query {
  votes {
    id
    yes
    weight
    participant {
      id
      name
    }
    proposal {
      id
      url
    }
  }
}

query {
  vote(id: 1) {
    id
    yes
    weight
    participant {
      id
      name
    }
    proposal {
      id
      url
    }
  }
}

query {
  delegations {
    id
    delegator {
      id
      name
    }
    delegate {
      id
      name
    }
  }
}

query {
  delegation(id: 1) {
    id
    delegator {
      id
      name
    }
    delegate {
      id
      name
    }
  }
}
```

Working mutations:

```
mutation {
  createVote(participantId: 1, proposalId: 1, yes: true) {
    participant {
      name
    }
    yes
  }
}
```

TODO:

* Graphql schemas resolvers for mutating votes and delegations, and for subscribing to voting results
* get some test coverage
* dockerize
* kuberize
* CI/CD
* logging
* monitoring
* perf tests
* JS widget
* next services: authentication, notifications
