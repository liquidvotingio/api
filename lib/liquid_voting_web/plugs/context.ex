defmodule LiquidVotingWeb.Plugs.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    # Absinthe.Plug calls Absinthe.run() with the options added to the `conn`.
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the organization id context based on the org-id header
  """
  def build_context(conn) do
    with [organization_id] <- get_req_header(conn, "org-id") do
      %{organization_id: organization_id}
    else
      _ -> %{}
    end
  end
end
