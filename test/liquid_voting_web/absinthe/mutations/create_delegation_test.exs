defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegationTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  @delegator_email "delegator@email.com"
  @delegate_email "delegate@email.com"
  @another_delegate_email "another-delegate@email.com"
  @proposal_url "https://www.proposal.com/my"
  @organization_id Ecto.UUID.generate()

  describe "create delegation with new participants" do
    test "with emails" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @delegate_email
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

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert delegation["delegator"]["email"] == @delegator_email
      assert delegation["delegator"]["name"] == nil
      assert delegation["delegate"]["email"] == @delegate_email
      assert delegation["delegate"]["name"] == nil
    end

    test "including a proposal url" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @delegate_email
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

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert delegation["proposalUrl"] == @proposal_url
    end

    test "including results in response, if present" do
      result = insert(:voting_result, proposal_url: @proposal_url)

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @delegate_email
      }", proposalUrl: "#{@proposal_url}") {
          delegator {
            email
          }
          delegate {
            email
          }
          proposalUrl
          votingResult {
            in_favor
            against
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: result.organization_id})

      assert delegation["votingResult"]["in_favor"] == 0
      assert delegation["votingResult"]["against"] == 0
    end

    test "with missing fields" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}") {
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

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert message == "Could not create delegation"
      assert details == %{delegate_id: ["can't be blank"], delegator_id: ["can't be blank"]}
    end
  end

  describe "create delegation with existing delegator and delegate" do
    setup do
      delegator = insert(:participant)
      delegate = insert(:participant)

      [
        delegator: delegator,
        delegate: delegate
      ]
    end

    test "with ids", context do
      query = """
      mutation {
        createDelegation(delegatorId: "#{context[:delegator].id}", delegateId: "#{
        context[:delegate].id
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert delegation["delegator"]["email"] == context[:delegator].email
      assert delegation["delegate"]["email"] == context[:delegate].email
    end

    test "with emails", context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate].email
      }") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert delegation["delegator"]["email"] == context[:delegator].email
      assert delegation["delegate"]["email"] == context[:delegate].email
    end

    test "with missing field", context do
      query = """
      mutation {
        createDelegation(delegatorId: "#{context[:delegator].id}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert message == "Could not create delegation"
      assert details == %{delegate_id: ["can't be blank"]}
    end
  end

  describe "create new global delegation for delegator with existing global delegation" do
    test "overwrites existing global delegation" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @delegate_email
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

  describe "create new proposal-specific delegation for delegator with existing delegation for same proposal" do
    test "overwrites existing proposal-specific delegation" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@delegator_email}", delegateEmail: "#{
        @delegate_email
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
end
