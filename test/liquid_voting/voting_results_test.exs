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
        organization_uuid: vote.organization_uuid
      ]
    end

    test "returns a result with the number of in_favor and no votes", context do
      assert %Result{in_favor: in_favor, against: against} =
               VotingResults.calculate_result!(
                 context[:proposal_url],
                 context[:organization_uuid]
               )

      assert in_favor == 1
      assert against == 0
    end

    test "returns the same result struct for a given proposal_url", context do
      %Result{uuid: uuid} =
        VotingResults.calculate_result!(context[:proposal_url], context[:organization_uuid])

      insert(:vote,
        proposal_url: context[:proposal_url],
        organization_uuid: context[:organization_uuid]
      )

      %Result{uuid: new_uuid} =
        VotingResults.calculate_result!(context[:proposal_url], context[:organization_uuid])

      assert uuid == new_uuid
    end
  end

  describe "create, get and list results" do
    setup do
      organization_uuid = Ecto.UUID.generate()

      [
        valid_attrs: %{
          in_favor: 42,
          against: 42,
          proposal_url: "https://proposals.com/1",
          organization_uuid: organization_uuid
        },
        update_attrs: %{
          in_favor: 43,
          against: 43,
          proposal_url: "https://proposals.com/1",
          organization_uuid: organization_uuid
        },
        invalid_attrs: %{
          in_favor: 42,
          against: 42,
          proposal_url: nil,
          organization_uuid: organization_uuid
        }
      ]
    end

    test "list_results/1 returns all results" do
      result = insert(:voting_result)
      assert VotingResults.list_results(result.organization_uuid) == [result]
    end

    test "get_result!/2 returns the result with given uuid" do
      result = insert(:voting_result)
      assert VotingResults.get_result!(result.uuid, result.organization_uuid) == result
    end

    test "get_result_by_proposal_url/2 returns the result with given proposal_url and organization_uuid" do
      result = insert(:voting_result)

      assert VotingResults.get_result_by_proposal_url(
               result.proposal_url,
               result.organization_uuid
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
