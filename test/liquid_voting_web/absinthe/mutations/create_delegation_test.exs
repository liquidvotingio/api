defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegationTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

  @new_delegator_email "new-delegator@email.com"
  @new_delegate_email "new-delegate@email.com"
  @proposal_url "https://www.proposal.com/my"
  @organization_id Ecto.UUID.generate()

  describe "create delegation with new participants" do
    test "with emails" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@new_delegator_email}", delegateEmail: "#{
        @new_delegate_email
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

      assert delegation["delegator"]["email"] == @new_delegator_email
      assert delegation["delegator"]["name"] == nil
      assert delegation["delegate"]["email"] == @new_delegate_email
      assert delegation["delegate"]["name"] == nil
    end

    test "including a proposal url" do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{@new_delegator_email}", delegateEmail: "#{
        @new_delegate_email
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
        createDelegation(delegatorEmail: "#{@new_delegator_email}", delegateEmail: "#{
        @new_delegate_email
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
        createDelegation(delegatorEmail: "#{@new_delegator_email}") {
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

  describe "create delegation" do
    setup do
      delegator = insert(:participant)
      delegate1 = insert(:participant)
      delegate2 = insert(:participant)

      [
        delegator: delegator,
        delegate1: delegate1,
        delegate2: delegate2
      ]
    end

    test "(global) for delegator who is delegator in pre-exisiting global delegation returns error",
         context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate1].email
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

      {:ok, %{data: %{"createDelegation" => _delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate2].email
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

      {:ok, %{data: %{"createDelegation" => _delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      # TODO: remove final step, below, and replace with assertion that specific
      # error message is returned by 2nd createDelegation mutation, above,
      # when we are clear exactly what that error message is/should be.
      query = """
      query {
        delegations {
          id
        }
      }
      """

      {:ok, %{data: %{"delegations" => delegations}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      IO.inspect(delegations)
      IO.inspect(Enum.count(delegations))

      assert Enum.count(delegations) < 2
    end

    test "(proposal) for delegator who is delegator in pre-exisiting proposal delegation returns error",
         context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate1].email
      }", proposal_url: "#{@proposal_url}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => _delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegate2].email
      }", , proposal_url: "#{@proposal_url}") {
          delegator {
            email
          }
          delegate {
            email
          }
        }
      }
      """

      {:ok, %{data: %{"createDelegation" => _delegation}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      # TODO: remove final step, below, and replace with assertion that specific
      # error message is returned by 2nd createDelegation mutation, above,
      # when we are clear exactly what that error message is/should be.
      query = """
      query {
        delegations {
          id
        }
      }
      """

      {:ok, %{data: %{"delegations" => delegations}}} =
        Absinthe.run(query, Schema, context: %{organization_id: @organization_id})

      IO.inspect(delegations)
      IO.inspect(Enum.count(delegations))

      assert Enum.count(delegations) < 2
    end
  end
end
