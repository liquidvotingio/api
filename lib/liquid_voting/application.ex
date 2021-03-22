defmodule LiquidVoting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    OpenTelemetry.register_application_tracer(:liquid_voting)
    OpentelemetryPhoenix.setup()

    # List all child processes to be supervised
    children = [
      Geometrics.OpenTelemetry.Handler,
      LiquidVoting.Repo,
      {Phoenix.PubSub, name: LiquidVoting.PubSub},
      LiquidVotingWeb.Endpoint,
      supervisor(Absinthe.Subscription, [LiquidVotingWeb.Endpoint])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiquidVoting.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LiquidVotingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
