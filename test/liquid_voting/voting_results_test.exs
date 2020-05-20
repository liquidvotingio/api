defmodule LiquidVoting.VotingResultsTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.VotingResults
  alias LiquidVoting.VotingResults.Result

  describe "calculate_result!/1" do
    setup do
      vote = insert(:vote, yes: true)
      [
        proposal_url: vote.proposal_url,
        organization_uuid: vote.organization_uuid
      ]
    end

    test "returns a result with the number of yes and no votes", context do
      assert %Result{no: no, yes: yes} = VotingResults.calculate_result!(context[:proposal_url], context[:organization_uuid])
      assert no == 0
      assert yes == 1
    end

    test "returns the same result struct for a given proposal_url", context do
      %Result{id: id} = VotingResults.calculate_result!(context[:proposal_url], context[:organization_uuid])
      insert(:vote, proposal_url: context[:proposal_url], organization_uuid: context[:organization_uuid])
      %Result{id: new_id} = VotingResults.calculate_result!(context[:proposal_url], context[:organization_uuid])
      assert id == new_id
    end

  end

  describe "create, get and list results" do
    setup do
      organization_uuid = Ecto.UUID.generate
      [
        valid_attrs: %{
          no: 42,
          yes: 42,
          proposal_url: "https://proposals.com/1",
          organization_uuid: organization_uuid

        },
        update_attrs: %{
          no: 43,
          yes: 43,
          proposal_url: "https://proposals.com/1",
          organization_uuid: organization_uuid
        },
        invalid_attrs: %{
          no: 42,
          yes: 42,
          proposal_url: nil,
          organization_uuid: organization_uuid
        }
      ]
    end

    test "list_results/0 returns all results" do
      result = insert(:voting_result)
      assert VotingResults.list_results() == [result]
    end

    test "get_result!/1 returns the result with given id" do
      result = insert(:voting_result)
      assert VotingResults.get_result!(result.id) == result
    end

    test "get_result_by_proposal_url/1 returns the result with given proposal_url" do
      result = insert(:voting_result)
      assert VotingResults.get_result_by_proposal_url(result.proposal_url) == result
    end

    test "get_result_by_proposal_url/1 with invalid data returns error changeset" do
      assert VotingResults.get_result_by_proposal_url("https://invalid.com") == nil
    end

    test "create_result/1 with valid data creates a result", context do
      assert {:ok, %Result{} = result} = VotingResults.create_result(context[:valid_attrs])
      assert result.no == 42
      assert result.yes == 42
    end

    test "create_result/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = VotingResults.create_result(context[:invalid_attrs])
    end
  end
end
