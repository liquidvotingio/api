defmodule LiquidVoting.DelegationsTest do
  use LiquidVoting.DataCase
  import LiquidVoting.Factory

  alias LiquidVoting.Delegations
  alias LiquidVoting.Delegations.Delegation

  describe "delegations" do
    setup do
      delegator = insert(:participant)
      delegate = insert(:participant)
      another_delegate = insert(:participant)
      organization_id = Ecto.UUID.generate()

      [
        valid_attrs: %{
          delegator_id: delegator.id,
          delegate_id: delegate.id,
          organization_id: organization_id
        },
        update_attrs: %{
          delegator_id: delegator.id,
          delegate_id: another_delegate.id,
          organization_id: organization_id
        },
        invalid_attrs: %{
          delegator_id: delegator.id,
          delegate_id: nil,
          organization_id: nil
        }
      ]
    end

    test "list_delegations/1 returns all delegations for an organization_id" do
      delegation = insert(:delegation)
      assert Delegations.list_delegations(delegation.organization_id) == [delegation]
    end

    test "get_delegation!/2 returns the delegation with given id and organization_id" do
      delegation = insert(:delegation)

      assert Delegations.get_delegation!(delegation.id, delegation.organization_id) ==
               delegation
    end

    test "create_delegation/1 with valid data creates a delegation", context do
      assert {:ok, %Delegation{} = delegation} =
               Delegations.create_delegation(context[:valid_attrs])
    end

    test "create_delegation/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(context[:invalid_attrs])
    end

    test "create_delegation/1 with proposal urls creates a delegation", context do
      # Test long urls while at it
      proposal_url = """
      https://www.bigassstring.com/search?ei=WdznXfzyIoeT1fAP79yWqAc&q=chrome+extension+popup+js+xhr+onload+document.body&oq=chrome+extension+popup+js+xhr+onload+document.body&gs_l=psy-ab.3...309222.313422..314027...0.0..1.201.1696.5j9j1....2..0....1..gws-wiz.2OvPoKSwZ_I&ved=0ahUKEwi8g5fQspzmAhWHSRUIHW-uBXUQ4dUDCAs&uact=5"
      """

      args = Map.merge(context[:valid_attrs], %{proposal_url: proposal_url})
      assert {:ok, %Delegation{} = delegation} = Delegations.create_delegation(args)
    end

    test "create_delegation/1 with duplicate data returns error changeset", context do
      Delegations.create_delegation(context[:valid_attrs])
      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(context[:valid_attrs])
    end

    test "create global delegation for delegator who is delegator in pre-exisiting global delegation returns error changeset", context do
      Delegations.create_delegation(context[:valid_attrs])
    
      IO.inspect(context[:valid_attrs].organization_id)
      IO.inspect(context[:update_attrs].organization_id)
    
      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(context[:update_attrs])
    end

    test "update_delegation/2 with valid data updates the delegation", context do
      delegation = insert(:delegation)

      assert {:ok, %Delegation{} = delegation} =
               Delegations.update_delegation(delegation, context[:update_attrs])
    end

    test "delete_delegation/1 deletes the delegation" do
      delegation = insert(:delegation)
      assert {:ok, %Delegation{}} = Delegations.delete_delegation(delegation)

      assert_raise Ecto.NoResultsError, fn ->
        Delegations.get_delegation!(delegation.id, delegation.organization_id)
      end
    end

    test "change_delegation/1 returns a delegation changeset" do
      delegation = insert(:delegation)
      assert %Ecto.Changeset{} = Delegations.change_delegation(delegation)
    end
  end
end
