defmodule LiquidVoting.Metrics do
  def setup do
    LiquidVoting.Metrics.PhoenixInstrumenter.setup()
    LiquidVoting.Metrics.PipelineInstrumenter.setup()
    LiquidVoting.Metrics.RepoInstrumenter.setup()
    LiquidVoting.Metrics.PrometheusExporter.setup()

    # Prometheus.Registry.register_collector(:prometheus_process_collector)

    :telemetry.attach(
      "prometheus-ecto",
      [:liquid_voting, :repo, :query],
      &LiquidVoting.Metrics.RepoInstrumenter.handle_event/4,
      nil
    )
  end
end

defmodule LiquidVoting.Metrics.PhoenixInstrumenter do
  use Prometheus.PhoenixInstrumenter
end

defmodule LiquidVoting.Metrics.PipelineInstrumenter do
  use Prometheus.PlugPipelineInstrumenter

  def label_value(:request_path, conn) do
    case Phoenix.Router.route_info(
           LiquidVotingWeb.Router,
           conn.method,
           conn.request_path,
           ""
         ) do
      %{route: path} -> path
      _ -> "unkown"
    end
  end
end

defmodule LiquidVoting.Metrics.RepoInstrumenter do
  use Prometheus.EctoInstrumenter
end

defmodule LiquidVoting.Metrics.PrometheusExporter do
  use Prometheus.PlugExporter
end
