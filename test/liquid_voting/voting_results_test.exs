defmodule LiquidVoting.VotingResultsTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.VotingResults
  alias LiquidVoting.VotingResults.Result

  describe "calculate_result!/2" do
    setup do
      vote = insert(:vote, yes: true)

      [
        proposal_url: vote.proposal_url,
        organization_id: vote.organization_id
      ]
    end

    test "returns a result with the number of in_favor and no votes", context do
      assert %Result{in_favor: in_favor, against: against} =
               VotingResults.calculate_result!(
                 context[:proposal_url],
                 context[:organization_id]
               )

      assert in_favor == 1
      assert against == 0
    end

    test "returns the same result struct for a given proposal_url", context do
      %Result{id: id} =
        VotingResults.calculate_result!(context[:proposal_url], context[:organization_id])

      insert(:vote,
        proposal_url: context[:proposal_url],
        organization_id: context[:organization_id]
      )

      %Result{id: new_id} =
        VotingResults.calculate_result!(context[:proposal_url], context[:organization_id])

      assert id == new_id
    end
  end

  describe "create, get and list results" do
    setup do
      organization_id = Ecto.UUID.generate()

      [
        valid_attrs: %{
          in_favor: 42,
          against: 42,
          proposal_url: "https://proposals.com/1",
          organization_id: organization_id
        },
        update_attrs: %{
          in_favor: 43,
          against: 43,
          proposal_url: "https://proposals.com/1",
          organization_id: organization_id
        },
        invalid_attrs: %{
          in_favor: 42,
          against: 42,
          proposal_url: nil,
          organization_id: organization_id
        }
      ]
    end

    test "list_results/1 returns all results" do
      result = insert(:voting_result)
      assert VotingResults.list_results(result.organization_id) == [result]
    end

    test "get_result!/2 returns the result with given id" do
      result = insert(:voting_result)
      assert VotingResults.get_result!(result.id, result.organization_id) == result
    end

    test "get_result_by_proposal_url/2 returns the result with given proposal_url and organization_id" do
      result = insert(:voting_result)

      assert VotingResults.get_result_by_proposal_url(
               result.proposal_url,
               result.organization_id
             ) == result
    end

    test "get_result_by_proposal_url/2 with invalid data returns nil" do
      assert VotingResults.get_result_by_proposal_url("https://invalid.com", Ecto.UUID.generate()) ==
               nil
    end

    test "create_result/1 with valid data creates a result", context do
      assert {:ok, %Result{} = result} = VotingResults.create_result(context[:valid_attrs])
      assert result.in_favor == 42
      assert result.against == 42
    end

    test "create_result/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = VotingResults.create_result(context[:invalid_attrs])
    end
  end
end
