# Liquid Voting as a Service (POC)

This project is part fun itch scratcher, part resume-driven development.

The itch is to implement a lightweight liquid voting service that can be easily plugged into proposal-making platforms of different kinds.

The RDD is to have a showcase for work with Elixir, Graphql, micro-services arch, Docker and Kubernetes. And reliability engineering stuff: CI/CD, monitoring, logging, perf tests.

As of now this a proof of concept, just started in the last few days. Just a Phoenix app skeleton with a Voting context, and Participant, Proposal, Vote and Delegation models. Very simplistic logic. No API yet. Auth and tests will be left for later, for speed of prototyping.

TODO:

* VotingResult model
* Graphql API for voting, delegating and subscribing to voting results
* dockerization
* kuberization
* tests
* logging
* monitoring
* perf tests
* CI/CD
* JS widget
* Auth
