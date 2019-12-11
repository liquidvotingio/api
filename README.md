# Liquid Voting as a Service

[![Actions Status](https://github.com/oliverbarnes/liquid-voting-service/workflows/CI/badge.svg)](https://github.com/oliverbarnes/liquid-voting-service/actions?workflow=CI)

Proof of concept for a liquid voting service that aims to be easily plugged into proposal-making platforms of different kinds. Learn more about the idea and motivation [on this blog post](https://medium.com/@oliver_azevedo_barnes/liquid-voting-as-a-service-c6e17b81ac1b).

In this repo there's an Elixir/Phoenix GraphQL API implementing the most basic [liquid democracy](https://en.wikipedia.org/wiki/Liquid_democracy) concepts: participants, proposals, votes and delegations.

A [browser extension](https://github.com/oliverbarnes/liquid-voting-browser-ext), on another repo, interacts with it from any content that could use voting on. It's completely open at this point, down the line there will be different gradations of voter verification available.

There's [a dockerized version](https://hub.docker.com/r/oliverbarnes/liquid-voting-service) of the API microservice, and manifests to get a rudimentary Kubernetes deployment going. I've been playing with one on Google Kubernetes Engine. The intention here, besides my wanting to learn and gain experience with k8s, is to make the service easily deployable within a microservices context.

## Concepts and modeling

Participants are users with a name and email, and they can vote on external content (say a blog post, or a pull request), identified as proposal urls, or delegate their votes to another Participant who can then vote for them, or delegate both votes to a third Participant, and so on.

Votes are yes/no booleans and reference a voter (a Participant) and a proposal_url, and Delegations are references to a delegator (a Participant) and a delegate (another Participant).

Once each vote is created, delegates' votes will have a different VotingWeight based on how many delegations they've received.

A VotingResult is calculated taking the votes and their different weights into account. This is a resource the API exposes as a possible `subscription`, for real-time updates over Phoenix Channels.

The syntax for subscribing, and for all other queries and mutations, can be seen following the setup instructions below.

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
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_NAME=liquid_voting_dev \
  -e DB_HOST=host.docker.internal \
  -p 4000:4000 \
  oliverbarnes/liquid-voting-service:latest
```

(assuming you already have the database up and running)

You can run migrations by passing an `eval` command to the containerized app, like this:

```
docker run -it --rm \
  <same options>
  oliverbarnes/liquid-voting-service:latest eval "LiquidVoting.Release.migrate"
```

### Running it locally in a Kubernetes cluster on Docker for Mac

Moved these instructions to a [blog post](https://medium.com/@oliver_azevedo_barnes/setting-up-a-small-local-k8s-cluster-for-development-cb1c99c6320d?sk=5ced4762aa9e22396cf717135377c5b6), as they were getting lengthy and aren't really central to the README.


## Using the API

Once you're up and running, you can use [Absinthe](https://absinthe-graphql.org/)'s handy query runner GUI by opening [http://localhost:4000/graphiql](http://localhost:4000/graphiql).

Create votes and delegations using [GraphQL mutations](https://graphql.org/learn/queries/#mutations)

```
mutation {
  createVote(participantEmail: "jane@somedomain.com", proposalUrl:"https://github.com/user/repo/pulls/15", yes: true) {
    participant {
      email
    }
    yes
  }
}

mutation {
  createDelegation(proposalUrl: "https://github.com/user/repo/pulls/15", delegatorEmail: "nelson@somedomain.com", delegateEmail: "liz@somedomain.com") {
    delegator {
      email
    }
    delegate {
      email
    }
  }
}

mutation {
  createVote(participantEmail: "liz@somedomain.com", proposalUrl:"https://github.com/user/repo/pulls/15", yes: false) {
    participant {
      email
    }
    yes
  }
}

```

Then run some [queries](https://graphql.org/learn/queries/#fields):

```
query {
  participants {
    email
    delegations_received {
      delegator {
        email
      }
      delegate {
        email
      }
    }
  }
}

query {
  participant(id: 1) {
    email
    delegations_received {
      delegator {
        email
      }
      delegate {
        email
      }
    }
  }
}

query {
  votes {
    yes
    weight
    proposalUrl
    participant {
      email
    }
  }
}

query {
  vote(id: 1) {
    yes
    weight
    proposalUrl
    participant {
      email
    }
  }
}

query {
  delegations {
    delegator {
      email
    }
    delegate {
      email
    }
  }
}

query {
  delegation(id: 1) {
    delegator {
      email
    }
    delegate {
      email
    }
  }
}

query {
  votingResult(proposalUrl: "https://github.com/user/repo/pulls/15") {
    yes
    no
    proposalUrl
  }
}
```

And [subscribe](https://github.com/absinthe-graphql/absinthe/blob/master/guides/subscriptions.md) to voting results (which will react to voting creation):

```
subscription {
  votingResultChange(proposalUrl:"https://github.com/user/repo/pulls/15") {
    yes
    no
    proposal_url
  }
}
```

To see this in action, open a second graphiql window and run `createVote` mutations there, and watch the subscription responses come through on the first one.

With the examples above, the `yes` count should be `1`, and `no` should be `2` since `liz@somedomain.com` had a delegation from `nelson@somedomain.com`.

## Notes:

* No app auth, few validations, and less test coverage than ideal, to keep prototyping fast (for now).
* Auth will be implemented as a separate micro-service

## TODO

* browser extension interacting with the API - [in progress](https://github.com/oliverbarnes/liquid-voting-browser-ext/issues/3)
* next services: [authentication](https://github.com/oliverbarnes/liquid-voting-service/issues/15), [notifications](https://github.com/oliverbarnes/liquid-voting-service/issues/13)
* [continuous delivery](https://github.com/oliverbarnes/liquid-voting-service/issues/4)
* perf tests
* logging with ELK stack
* blockchain integration: Blockstack, possibly others later
