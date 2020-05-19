defmodule LiquidVotingWeb.Absinthe.Queries.DelegationsTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "query delegations" do
    test "without a proposal url" do
      delegation = insert(:delegation)

      query = """
      query {
        delegations {
          delegate {
            email
          }
          delegator {
            email
          }
          votingResult {
            yes
            no
            proposalUrl
          } 
        }
      }
      """

      {:ok, %{data: %{"delegations" => [payload | _]}}} = Absinthe.run(query, Schema, context: %{organization_uuid: Ecto.UUID.generate})

      assert payload["delegate"]["email"] == delegation.delegate.email
      assert payload["delegator"]["email"] == delegation.delegator.email
      assert payload["votingResult"] == nil
    end
  end
end