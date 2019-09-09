alias LiquidDem.Repo
alias LiquidDem.Voting
alias LiquidDem.VotingResults

proposal = Voting.create_proposal!(%{url: "some.proposal.on.github.com"})

participant = Voting.create_participant!(%{name: "Lucia Coelho"})
delegator = Voting.create_participant!(%{name: "Zubin Kurozawa"})
delegator2 = Voting.create_participant!(%{name: "Louie Louie"})

Voting.create_delegation!(%{
  delegator_id: delegator.id,
  delegate_id: participant.id
})

Voting.create_delegation!(%{
  delegator_id: delegator2.id,
  delegate_id: participant.id
})

participant = Repo.preload(participant, :delegations_received)

vote =
  Voting.create_vote!(%{
    yes: true,
    proposal_id: proposal.id,
    participant_id: participant.id
  })

participant2 = Voting.create_participant!(%{name: "Francine Dunlop"})

vote =
  Voting.create_vote!(%{
    yes: false,
    proposal_id: proposal.id,
    participant_id: participant2.id
  })

VotingResults.calculate_result(proposal)
|> IO.inspect

