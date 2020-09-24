defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.ExistingDelegationsTest do
  use LiquidVotingWeb.ConnCase

  alias LiquidVotingWeb.Schema.Schema

  @delegator_email "delegator@email.com"
  @delegate_email "delegate@email.com"
  @another_delegate_email "another-delegate@email.com"
  @proposal_url "https://www.proposal.com/my"
  @another_proposal_url "https://www.proposal.com/another"
  @organization_id Ecto.UUID.generate()

  describe "create global delegation for delegator with existing global delegation to different delegate" do
    test "overwrites existing global delegation" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}") {
          delegator {
            email
            name
          }
          delegate {
            email
            name
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert original_delegation["delegator"]["email"] == @delegator_email
      assert original_delegation["delegate"]["email"] == @delegate_email

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @another_delegate_email
      }") {
          delegator {
            email
            name
          }
          delegate {
            email
            name
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => modified_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert modified_delegation["delegator"]["email"] == @delegator_email
      assert modified_delegation["delegate"]["email"] == @another_delegate_email
    end
  end

  describe "create global delegation for delegator with existing proposal delegations to same delegate" do
    test "deletes proposal specific delegations for same delegator/delegate pair" do
      # First, create a proposal-specific delegation.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}", proposalUrl: "#{
        @proposal_url
      }") {
          id
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => proposal_delegation_1}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert proposal_delegation_1["proposalUrl"] == @proposal_url

      # Second, create another proposal-specific delegation (same participants, different proposalUrl).
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}", proposalUrl: "#{
        @another_proposal_url
      }") {
          id
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => proposal_delegation_2}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert proposal_delegation_2["proposalUrl"] == @another_proposal_url

      # TODO? Insert 3rd proposal-specific delegation to DIFFERENT delegate, for testing deletion of wrong delegations does not occur?

      # Third, create a global delegation for the same participants.
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => global_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert global_delegation["delegator"]["email"] == @delegator_email
      assert global_delegation["delegate"]["email"] == @delegate_email

      # Fourth, search for proposal_delgation_1 (should return error).
      query = """
      query {
        delegation(id: "#{proposal_delegation_1["id"]}") {
          id
        }
      }
      """

      assert_raise Ecto.NoResultsError, fn ->
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})
      end

      # Lastly, search for proposal_delegation_2 (should return error).
      query = """
      query {
        delegation(id: "#{proposal_delegation_2["id"]}") {
          id
        }
      }
      """

      assert_raise Ecto.NoResultsError, fn ->
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})
      end

      # TODO? Search for 3rd proposal-specific delegation to DIFFERENT delegate, and assert can be found (not deleted)?
    end
  end

  describe "create new proposal-specific delegation for delegator with existing delegation for same proposal" do
    test "overwrites existing proposal-specific delegation" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}", proposalUrl: "#{
        @proposal_url
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert original_delegation["delegator"]["email"] == @delegator_email
      assert original_delegation["delegate"]["email"] == @delegate_email

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @another_delegate_email
      }", proposalUrl: "#{@proposal_url}") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => modified_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert modified_delegation["delegator"]["email"] == @delegator_email
      assert modified_delegation["delegate"]["email"] == @another_delegate_email
      assert original_delegation["proposalUrl"] == modified_delegation["proposalUrl"]
    end
  end

  describe "create proposal delegation for delegator with existing global delegation to same delegate" do
    test "returns error" do
      # first, create a global delegation
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => original_delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert original_delegation["delegator"]["email"] == @delegator_email
      assert original_delegation["delegate"]["email"] == @delegate_email

      # then, attempt to create a proposal-specific delegation for same delegator and delegate
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{@delegate_email}", proposalUrl: "#{
        @proposal_url
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
        }
      }
      """

      # TODO: Improve structure of error returned to absinthe (this is way too messy)
      {:ok, %{errors: [%{details: details, message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      assert message == "Could not create delegation."
      assert details == "A global delegation for the same participants already exists."
    end
  end
end
