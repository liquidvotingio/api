defmodule LiquidVotingWeb.Absinthe.Mutations.CreateDelegation.ExistingDelegatorDelegateTest do
  use LiquidVotingWeb.ConnCase
  import LiquidVoting.Factory

  alias LiquidVotingWeb.Schema.Schema

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

    test "with identical emails for delegator and delegate", context do
      query = """
      mutation {
        createDelegation(delegatorEmail: "#{context[:delegator].email}", delegateEmail: "#{
        context[:delegator].email
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

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert message == "Could not create delegation"
      assert details == %{delegate_id: ["delegator and delegate must be different"]}
    end

    test "with identical ids for delegator and delegate", context do
      query = """
      mutation {
        createDelegation(delegatorId: "#{context[:delegator].id}", delegateId: "#{
        context[:delegator].id
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

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_id: Ecto.UUID.generate()})

      assert message == "Could not create delegation"
      assert details == %{delegate_id: ["delegator and delegate must be different"]}
    end
  end

end
