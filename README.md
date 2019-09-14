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

Or, you can run a dockerized version that is in the works using Elixir 1.9 releases.

To run it locally, connecting to your local database (after having it setup with `mix ecto.setup`):

```
docker build -t liquid_voting:latest .
docker run -it --rm \
-e SECRET_KEY_BASE=$(mix phx.gen.secret) \
-e APP_PORT=4000 \
-e DATABASE_URL='ecto://postgres:postgres@host.docker.internal/liquid_voting_dev' \
-e DB_POOL_SIZE=10 \
-p 4000:4000 \
liquid_voting:latest
open http://localhost:4000/graphiql
```

Once you're up and running, you can run these sample queries on Graphiql:

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

Mutations:

```
mutation {
  createVote(proposalId: 1, participantId: 1, yes: true) {
    participant {
      name
    }
    yes
  }
}

mutation {
  createDelegation(proposalId: 1, delegatorId: 1, delegateId: 2) {
    delegator {
      name
    }
    delegate {
      name
    }
  }
}
```

Subscription to voting results (which will react to voting creation):

```
subscription {
  votingResultChange(proposalId:1) {
    id
    yes
    no
    proposal {
      url
    }
  }
}
```

To see this in action, open a second graphiql window and run `createVote` mutations there, and watch the subscription responses come through.

Notes:

* No auth, validations or tests yet, to keep prototyping as fast as possible

TODO:

* kuberize
* CI/CD
* validations
* some tests
* logging
* monitoring
* perf tests
* JS widget
* next services: authentication, notifications
