# Liquid Voting as a Service (PoC)

Proof of concept for a liquid voting service that can be easily plugged into proposal-making platforms of different kinds.

It consists of a Elixir/Phoenix GraphQL API implementing the most basic [liquid democracy](https://en.wikipedia.org/wiki/Liquid_democracy) concepts: participants, proposals, votes and delegations.

There's a dockerized version and a rudimentary local Kubernetes deployment for it.

## Modeling

Participants are simply names with emails, Proposals are links to external content (say a blog post, or a pull request), Votes are booleans and references to a voter (a Participant) and a Proposal, and Delegations are references to a delegator (a Participant) and a delegate (another Participant).

A participant can vote for or against a proposal, or delegate to another participant so they can vote for them. Once each vote is cast, delegates' votes will have a different weight based on how many delegations they've received.

A VotingResult is calculated taking the votes and their different weights into account. This is a resource the API exposes as a possible `subscription`, for real-time updates over Phoenix Channels.

The syntax for this, and for all other queries and mutations, can be seen following the setup.

## Local setup

### Building from the repo

You'll need Elixir 1.9, Phoenix 1.4.10 and Postgres 10 installed.

Clone the repo and:

```
mix deps.get
mix ecto.setup
mix phx.server
```

### Running the dockerized version

```
docker run -it --rm \
-e SECRET_KEY_BASE=$(mix phx.gen.secret) \
-e APP_PORT=4000 \
-e DATABASE_URL='ecto://postgres:postgres@host.docker.internal/liquid_voting_dev' \
-e DB_POOL_SIZE=10 \
-p 4000:4000 \
oliverbarnes/liquid-voting-service:latest
```

(assuming you already have the database up and running)

You can run migrations by passing an `eval` command to the containerized app, like this:

```
docker run -it --rm \
<options>
oliverbarnes/liquid-voting-service:latest eval "LiquidVoting.Release.migrate"
```

### Running it locally in a Kubernetes cluster on Docker for Mac

Install the [ingress-nginx controller](https://github.com/kubernetes/ingress-nginx):

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
```

Then apply the app's manifest files (if you use [Tilt](https://tilt.dev/) you can do `tilt up` instead):

```
kubectl apply -f k8s/nginx-ingress-load-balancer.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/database-persistent-volume-claim.yaml
kubectl apply -f k8s/database-service.yaml
kubectl apply -f k8s/database-deployment.yaml
kubectl apply -f k8s/liquid-voting-service.yaml
kubectl apply -f k8s/liquid-voting-deployment.yaml
```

And run the migrations from within the app deployment:

```
kubectl get pods
kubectl exec -ti liquid-voting-deployment-pod \
--container liquid-voting \
-- /opt/app/_build/prod/rel/liquid_voting/bin/liquid_voting \
eval "LiquidVoting.Release.migrate"
```



## Using the API

Once you're up and running, you can use [Absinthe](https://absinthe-graphql.org/)'s handy query runner GUI by opening [http://localhost:4000/graphiql](http://localhost:4000/graphiql).

Available queries:

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

To see this in action, open a second graphiql window and run `createVote` mutations there, and watch the subscription responses come through on the first one.

## Notes:

* No auth, validations or tests yet, to keep prototyping as fast as possible

## TODO

* CI/CD
* validations
* some tests
* logging
* monitoring
* perf tests
* JS widget
* next services: authentication, notifications
