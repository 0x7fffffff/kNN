defmodule KNN do
  @moduledoc """
  Documentation for KNN.
  """

  use Application

  import Supervisor.Spec

  require Logger

  def start(_type, _args) do
    Logger.debug "Starting node \"" <> System.get_env("NODE_NAME") <> "\" of type: \"" <> System.get_env("NODE_TYPE") <> "\""
    children = case System.get_env("NODE_TYPE") do
      "command" ->
        [
          worker(KNN.Command, [], [name: KNN.Command])
        ]
      "store" ->
        []
      "mesh" ->
        []
    end

    # TODO: Investigate different supervision strategies, and try to pick ones that
    # are good fits for the individual child processes.
    # https://hexdocs.pm/elixir/Supervisor.html#module-strategies
    #
    opts = [strategy: :one_for_one, name: KNN.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
