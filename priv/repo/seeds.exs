alias LiquidDem.Repo
alias LiquidDem.Voting.{Proposal,Participant,Vote}

proposal =
  %Proposal{
    url: "some.proposal.on.github.com"
  }
  |> Repo.insert!

participant =
  %Participant{
    name: "Lucia Coelho"
  }
  |> Repo.insert!

vote =
  %Vote{
    yes_or_no: true,
    proposal: proposal,
    participant: participant
  }
  |> Repo.insert!