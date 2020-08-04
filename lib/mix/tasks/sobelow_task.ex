defmodule Mix.Tasks.SobelowTask do
  use Mix.Task

  @shortdoc "blah blah"
  def run(_) do
    Mix.Tasks.Sobelow.run(~w|build release|)
  end
end
