defmodule LiquidVotingWeb.Absinthe.Queries.DelegationsTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  describe "query delegations" do
    test "without a proposal url" do
      delegation = insert(:delegation)
      organization_id = delegation.organization_id

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
            in_favor
            against
            proposalUrl
          } 
        }
      }
      """

      {:ok, %{data: %{"delegations" => [payload | _]}}} =
        Absinthe.run(query, Schema, context: %{organization_id: organization_id})

      assert payload["delegate"]["email"] == delegation.delegate.email
      assert payload["delegator"]["email"] == delegation.delegator.email
      assert payload["votingResult"] == nil
    end
  end
end
