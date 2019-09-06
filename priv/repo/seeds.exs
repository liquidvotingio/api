alias LiquidDem.Repo
alias LiquidDem.Voting

proposal = Voting.create_proposal!(%{url: "some.proposal.on.github.com"})

participant = Voting.create_participant!(%{name: "Lucia Coelho"})

vote =
  Voting.create_vote!(%{
    yes_or_no: true,
    proposal_id: proposal.id,
    participant_id: participant.id
  })