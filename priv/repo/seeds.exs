alias LiquidDem.Repo
alias LiquidDem.Voting

proposal = Voting.create_proposal!(%{url: "some.proposal.on.github.com"})

result = VotingResults.create_result!(%{proposal_id: proposal.id})

participant = Voting.create_participant!(%{name: "Lucia Coelho"})
another_participant = Voting.create_participant!(%{name: "Zubin Kurozawa"})

Voting.create_delegation!(%{
  delegator_id: another_participant.id,
  delegate_id: participant.id
})

Repo.preload(participant.delegations_received)

vote =
  Voting.create_vote!(%{
    yes_or_no: true,
    proposal_id: proposal.id,
    participant_id: participant.id
  })

result
|> VotingResults.update_result(vote)