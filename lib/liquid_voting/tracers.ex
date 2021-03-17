defmodule LiquidVoting.Tracers do
  require OpenTelemetry.Tracer, as: Tracer

  # Helper functions for our use of OpenTelemetry.Honeycomb.Exporter

  # Sets general attributes to send in Tracer.with_span block.
  def set_attributes(env, vars) do
    Tracer.set_attributes([
      {:action, env.function},
      {:request_id, Logger.metadata()[:request_id]},
      {:vars, vars}
    ])
  end

end