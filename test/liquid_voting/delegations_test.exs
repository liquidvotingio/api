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
      proposal_url = "https://www.someorg/proposalX"
      another_proposal_url = "https://someorg/another-proposal"

      [
        proposal_url: proposal_url,
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
        },
        valid_proposal_specific_attrs: %{
          delegator_id: delegator.id,
          delegate_id: delegate.id,
          organization_id: organization_id,
          proposal_url: proposal_url
        },
        another_proposal_url: another_proposal_url
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

    test "create_delegation/1 with same participant as delegator and delegate returns error changeset" do
      participant = insert(:participant)

      args = %{
        delegator_id: participant.id,
        delegate_id: participant.id,
        organization_id: Ecto.UUID.generate()
      }

      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(args)
    end

    test "create_delegation/1 with proposal url creates a delegation", context do
      # Test long urls while at it
      proposal_url = """
      https://www.bigassstring.com/search?ei=WdznXfzyIoeT1fAP79yWqAc&q=chrome+extension+popup+js+xhr+onload+document.body&oq=chrome+extension+popup+js+xhr+onload+document.body&gs_l=psy-ab.3...309222.313422..314027...0.0..1.201.1696.5j9j1....2..0....1..gws-wiz.2OvPoKSwZ_I&ved=0ahUKEwi8g5fQspzmAhWHSRUIHW-uBXUQ4dUDCAs&uact=5"
      """

      args = Map.merge(context[:valid_attrs], %{proposal_url: proposal_url})
      assert {:ok, %Delegation{} = delegation} = Delegations.create_delegation(args)
    end

    # FAILING!!
    # Following PR #109 https://github.com/liquidvotingio/api/issues/109
    # See issue #28 https://github.com/liquidvotingio/api/issues/128
    @tag :skip
    test "create_delegation/1 with duplicate global delegation data returns error changeset" do
      original_delegation = insert(:delegation)

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: original_delegation.delegate_id,
        organization_id: original_delegation.organization_id
      }

      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(args)
    end

    test "create_delegation/1 with duplicate proposal-specific data returns error changeset",
         context do
      original_delegation = insert(:delegation, proposal_url: context[:proposal_url])

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: original_delegation.delegate_id,
        organization_id: original_delegation.organization_id,
        proposal_url: original_delegation.proposal_url
      }

      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(args)
    end

    # FAILING!!
    # Following PR #109 https://github.com/liquidvotingio/api/issues/109
    # See issue #125:https://github.com/liquidvotingio/api/issues/125
    @tag :skip
    test "create_delegation/1 with proposal-specifc data returns error if global delegation for same delegator/delegate pair exists",
         context do
      original_delegation = insert(:delegation)

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: original_delegation.delegate_id,
        organization_id: original_delegation.organization_id,
        proposal_url: context[:proposal_url]
      }

      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(args)
    end

    # FAILING!!
    # Following PR #109 https://github.com/liquidvotingio/api/issues/109
    # See issue #125:https://github.com/liquidvotingio/api/issues/125
    @tag :skip
    test "create_delegation/1 with global delegation data returns error if proposal-specific delegation for same delegator/delegate pair exists",
         context do
      original_delegation = insert(:delegation, proposal_url: context[:proposal_url])

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: original_delegation.delegate_id,
        organization_id: original_delegation.organization_id
      }

      assert {:error, %Ecto.Changeset{}} = Delegations.create_delegation(args)
    end

    test "create_delegation/1 creates second different proposal-specific delegation for same delegator/delegate pair",
         context do
      original_delegation = insert(:delegation, proposal_url: context[:proposal_url])

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: original_delegation.delegate_id,
        organization_id: original_delegation.organization_id,
        proposal_url: context[:another_proposal_url]
      }

      assert {:ok, %Delegation{}} = Delegations.create_delegation(args)
    end

    test "upsert_delegation/1 with valid proposal_specific delegation data creates a delegation",
         context do
      assert {:ok, %Delegation{} = delegation} =
               Delegations.upsert_delegation(context[:valid_proposal_specific_attrs])
    end

    test "upsert_delegation/1 with valid global delegation data creates a delegation", context do
      assert {:ok, %Delegation{} = delegation} =
               Delegations.upsert_delegation(context[:valid_attrs])
    end

    test "upsert_delegation/1 with duplicate delegator and proposal_url updates the respective delegation",
         context do
      original_delegation = insert(:delegation, proposal_url: context[:proposal_url])
      new_delegate = insert(:participant)

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: new_delegate.id,
        organization_id: original_delegation.organization_id,
        proposal_url: original_delegation.proposal_url
      }

      assert {:ok, %Delegation{} = modified_delegation} = Delegations.upsert_delegation(args)
      assert original_delegation.organization_id == modified_delegation.organization_id
      assert original_delegation.delegate_id != modified_delegation.delegate_id
      assert original_delegation.delegator_id == modified_delegation.delegator_id
    end

    test "upsert_delegation/1 for global delegation with duplicate delegator updates the respective delegation" do
      original_delegation = insert(:delegation)
      new_delegate = insert(:participant)

      args = %{
        delegator_id: original_delegation.delegator_id,
        delegate_id: new_delegate.id,
        organization_id: original_delegation.organization_id
      }

      assert {:ok, %Delegation{} = modified_delegation} = Delegations.upsert_delegation(args)
      assert original_delegation.organization_id == modified_delegation.organization_id
      assert original_delegation.delegate_id != modified_delegation.delegate_id
      assert original_delegation.delegator_id == modified_delegation.delegator_id
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

    # test "delete_delegation/1 without proposal_url does not delete a proposal-specific delegation" do
    # actually, I think this may only be a problem at absinthe layer, since at this level the actual
    # delegation is required. Thus, I think the problem arises when we find a delegation to delete
    # based on the params passed into absinthe layer.

    # create a proposal specific delegation
    # attempt to delete delegation without proposal_url field
    # assert proposal-specific delegation still exists
    # end

    test "change_delegation/1 returns a delegation changeset" do
      delegation = insert(:delegation)
      assert %Ecto.Changeset{} = Delegations.change_delegation(delegation)
    end
  end
end
