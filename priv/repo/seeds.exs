# alias LiquidVoting.Repo
# alias LiquidVoting.Voting
# alias LiquidVoting.VotingResults

# participant = Voting.create_participant!(%{name: "Lucia Coelho", email: "lucia@coelho.com"})
# delegator = Voting.create_participant!(%{name: "Zubin Kurozawa", email: "zubin@kurozawa.com"})
# delegator2 = Voting.create_participant!(%{name: "Louie Louie", email: "louie@louie.com"})

# Voting.create_delegation!(%{
#   delegator_id: delegator.id,
#   delegate_id: participant.id
# })

# Voting.create_delegation!(%{
#   delegator_id: delegator2.id,
#   delegate_id: participant.id
# })

# participant = Repo.preload(participant, :delegations_received)
# proposal_url = "https://github.com/user/repo/pulls/15"

# vote =
#   Voting.create_vote!(%{
#     yes: true,
#     proposal_url: proposal_url,
#     participant_id: participant.id
#   })

# participant2 = Voting.create_participant!(%{name: "Francine Dunlop", email: "francine@dunlop.com"})

# vote =
#   Voting.create_vote!(%{
#     yes: false,
#     proposal_url: proposal_url,
#     participant_id: participant2.id
#   })

# VotingResults.calculate_result!(proposal_url)
# |> IO.inspect
