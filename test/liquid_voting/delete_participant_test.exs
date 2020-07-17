defmodule LiquidVoting.DeleteParticipantTest do
  use LiquidVoting.DataCase

  alias LiquidVoting.Voting

  # TODO: Delete this temporary debug file.

  # This test reproduces issue of exception raised by attempting to
  # delete a participant who is associated with a vote.

  describe "delete participant" do
    @valid_org_id Ecto.UUID.generate()

    @valid_participant_attrs %{
      name: "some name",
      email: "some@email.com",
      organization_id: @valid_org_id
    }
    
    test "delete participant who has an associated vote" do
      # do some stuff

      Voting.create_participant(@valid_participant_attrs)
      participant = Voting.get_participant_by_email("some@email.com", @valid_org_id)
      
      valid_vote_attrs = %{
        yes: true,
        weight: 1,
        participant_id: participant.id,
        proposal_url: "https://prop.com/1",
        organization_id: @valid_org_id
      }

      Voting.create_vote(valid_vote_attrs)

      Voting.delete_participant!(participant)

      # => ** (Ecto.ConstraintError) constraint error when attempting to delete struct:
     
      #   * votes_participant_id_fkey (foreign_key_constraint)
     
      #   If you would like to stop this constraint violation from raising an
      #   exception and instead add it as an error to your changeset, please
      #   call `foreign_key_constraint/3` on your changeset with the constraint
      #   `:name` as an option.
         
      #   The changeset has not defined any constraint.
         
      #   code: Voting.delete_participant!(participant)
      #   stacktrace:
      #     (ecto 3.4.5) lib/ecto/repo/schema.ex:700: anonymous fn/4 in Ecto.Repo.Schema.constraints_to_errors/3
      #     (elixir 1.10.3) lib/enum.ex:1396: Enum."-map/2-lists^map/1-0-"/2
      #     (ecto 3.4.5) lib/ecto/repo/schema.ex:685: Ecto.Repo.Schema.constraints_to_errors/3
      #     (ecto 3.4.5) lib/ecto/repo/schema.ex:666: Ecto.Repo.Schema.apply/4
      #    (ecto 3.4.5) lib/ecto/repo/schema.ex:439: anonymous fn/10 in Ecto.Repo.Schema.do_delete/4
      #     (ecto 3.4.5) lib/ecto/repo/schema.ex:190: Ecto.Repo.Schema.delete!/4
      #     test/liquid_voting/delete_participant_test.exs:36: (test)

      assert 1 == 1
    end
  end

end
