defmodule LiquidVoting.VotingMethodsTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.VotingMethods
  alias LiquidVoting.VotingMethods.VotingMethod

  describe "voting_methods" do
    @valid_attrs %{
      name: "a_cool_voting_method",
      organization_id: Ecto.UUID.generate()
    }

    @invalid_attrs %{name: 42, organization_id: nil}

    test "get_voting_method!/2 returns the voting method for given id and organization_id" do
      voting_method = insert(:voting_method)
      assert VotingMethods.get_voting_method!(voting_method.id, voting_method.organization_id) == voting_method
    end

    test "list_voting_methods_by_org/1 returns all voting_methods for an organization_id" do
      voting_method = insert(:voting_method)

      assert VotingMethods.list_voting_methods_by_org(voting_method.organization_id) == [
               voting_method
             ]
    end

    test "upsert_voting_method/1 with valid data inserts a new voting method" do
      assert {:ok, %VotingMethod{} = voting_method} =
               VotingMethods.upsert_voting_method(@valid_attrs)

      assert voting_method.name == @valid_attrs[:name]
      assert voting_method.organization_id == @valid_attrs[:organization_id]
    end

    test "upsert_voting_method/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VotingMethods.upsert_voting_method(@invalid_attrs)
    end

    test "upsert_voting_method/1 with existing valid data fetches matching voting_method record" do
      insert(:voting_method,
        name: @valid_attrs[:name],
        organization_id: @valid_attrs[:organization_id]
      )

      assert {:ok, %VotingMethod{} = voting_method} =
               VotingMethods.upsert_voting_method(@valid_attrs)

      assert voting_method.name == @valid_attrs[:name]
      assert voting_method.organization_id == @valid_attrs[:organization_id]
    end

    test "upsert_voting_method/1 with existing valid does not add a duplicate record" do
      voting_method =
        insert(:voting_method,
          name: @valid_attrs[:name],
          organization_id: @valid_attrs[:organization_id]
        )

      assert Enum.count(VotingMethods.list_voting_methods_by_org(voting_method.organization_id)) ==
               1

      assert {:ok, %VotingMethod{}} = VotingMethods.upsert_voting_method(@valid_attrs)

      assert Enum.count(VotingMethods.list_voting_methods_by_org(voting_method.organization_id)) ==
               1
    end
  end
end
