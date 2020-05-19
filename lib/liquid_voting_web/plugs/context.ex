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
  Return the organization uuid context based on the org-uuid header
  """
  def build_context(conn) do
    with [org_uuid] <- get_req_header(conn, "org-uuid") do
      %{org_uuid: org_uuid}
    else
      _ -> %{}
    end
  end
end