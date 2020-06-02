# Liquid Voting as a Service

[![Actions Status](https://github.com/liquidvotingio/api/workflows/CI/CD/badge.svg)](https://github.com/liquidvotingio/api/actions?query=workflow%3ACI%2FCD)

A liquid voting service that aims to be easily plugged into proposal-making platforms of different kinds. Learn more about the idea and motivation [on this blog post](https://medium.com/@oliver_azevedo_barnes/liquid-voting-as-a-service-c6e17b81ac1b).

In this repo there's an Elixir/Phoenix GraphQL API implementing the most basic [liquid democracy](https://en.wikipedia.org/wiki/Liquid_democracy) concepts: participants, proposals, votes and delegations.

It's deployed on https://api.liquidvoting.io. See sample queries below, in [Using the API](https://github.com/liquidvotingio/api#using-the-api).

There's [a dockerized version](https://github.com/liquidvotingio/api/packages/81472) of the API. The live API is running on Google Kubernetes Engine. The intention is to make the service easily deployable within a microservices/cloud native context.

You can follow the [project backlog here](https://github.com/orgs/liquidvotingio/projects/1).

The live API is getting ready to be used in production platforms. If you're interested, [let me know](mailto:oli.azevedo.barnes@gmail.com) so I can learn more about your project, and I'll provide you with an access key.

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
  docker.pkg.github.com/liquidvotingio/api/api:latest
```

(assuming you already have the database up and running)

You can run migrations by passing an `eval` command to the containerized app, like this:

```
docker run -it --rm \
  <same options>
  docker.pkg.github.com/liquidvotingio/api/api:latest eval "LiquidVoting.Release.migrate"
```

### Once you're up and running

You can use [Absinthe](https://absinthe-graphql.org/)'s handy query runner GUI by opening [http://localhost:4000/graphiql](http://localhost:4000/graphiql).

## Using the API

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
    votingResult {
      yes
      no
    }
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
