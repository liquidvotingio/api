defmodule LiquidVotingWeb.Absinthe.Mutations.CreateParticipantTest do
  use LiquidVotingWeb.ConnCase

  alias LiquidVotingWeb.Schema.Schema

  describe "create participant" do
    @new_participant_email "noob@email.com"
    @new_participant_name "Noobie"
    @another_name "Another Name"
    @invalid_email "invalid_email"
    @organization_uuid Ecto.UUID.generate()

    test "with a new participant's email and name" do
      query = """
      mutation {
        createParticipant(email: "#{@new_participant_email}", name: "#{@new_participant_name}") {
          name
          email
        }
      }
      """

      {:ok, %{data: %{"createParticipant" => participant}}} =
        Absinthe.run(query, Schema, context: %{organization_uuid: @organization_uuid})

      assert participant["email"] == @new_participant_email
      assert participant["name"] == @new_participant_name
    end

    test "with an existing participant's email returns error changeset" do
      query = """
      mutation {
        createParticipant(email: "#{@new_participant_email}", name: "#{@new_participant_name}") {
          name
          email
        }
      }
      """

      {:ok, _} = Absinthe.run(query, Schema, context: %{organization_uuid: @organization_uuid})

      query = """
      mutation {
        createParticipant(email: "#{@new_participant_email}", name: "#{@another_name}") {
          name
          email
        }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_uuid: @organization_uuid})

      assert message == "Could not create participant"
      assert details == %{email: ["has already been taken"]}
    end

    test "with only a new participant's email returns error changeset" do
      query = """
      mutation {
        createParticipant(email: "#{@new_participant_email}") {
          name
          email
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_uuid: @organization_uuid})

      assert to_charlist(message) == 'In argument "name": Expected type "String!", found null.'
    end

    test "with only a new participant's name returns error changeset" do
      query = """
      mutation {
        createParticipant(name: "#{@new_participant_name}") {
          name
          email
        }
      }
      """

      {:ok, %{errors: [%{message: message}]}} =
        Absinthe.run(query, Schema, context: %{organization_uuid: @organization_uuid})

      assert to_charlist(message) == 'In argument "email": Expected type "String!", found null.'
    end

    test "with invalid email format returns error changeset" do
      query = """
      mutation {
        createParticipant(email: "#{@invalid_email}", name: "#{@new_participant_name}") {
          name
          email
        }
      }
      """

      {:ok, %{errors: [%{message: message, details: details}]}} =
        Absinthe.run(query, Schema, context: %{organization_uuid: @organization_uuid})

      assert message == "Could not create participant"
      assert details == %{email: ["is invalid"]}
    end
  end
end
