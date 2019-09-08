alias LiquidDem.Repo
alias LiquidDem.Voting
alias LiquidDem.VotingResults

proposal = Voting.create_proposal!(%{url: "some.proposal.on.github.com"})

participant = Voting.create_participant!(%{name: "Lucia Coelho"})
another_participant = Voting.create_participant!(%{name: "Zubin Kurozawa"})

Voting.create_delegation!(%{
  delegator_id: another_participant.id,
  delegate_id: participant.id
})

participant = Repo.preload(participant, :delegations_received)
weight = length(participant.delegations_received) + 1

vote =
  Voting.create_vote!(%{
    yes: true,
    proposal_id: proposal.id,
    participant_id: participant.id,
    weight: weight
  })


result = 
  VotingResults.create_result!(%{
    proposal_id: proposal.id,
    yes: vote.weight
  })

IO.inspect(result)

