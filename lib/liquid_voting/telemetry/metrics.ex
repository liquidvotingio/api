# lib/liquid_voting/telemetry/metrics.ex
defmodule LiquidVoting.Telemetry.Metrics do
  require Logger
  alias LiquidVoting.Telemetry.StatsdReporter

  def handle_event([:phoenix, :request], %{duration: dur}, metadata, _config) do
    # do some stuff like log a message or report metrics to a service like StatsD
    Logger.info("Received [:phoenix, :request] event. Request duration: #{dur}, Route: #{metadata.request_path}")
  end
end