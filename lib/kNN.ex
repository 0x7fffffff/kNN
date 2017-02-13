defmodule KNN do
  @moduledoc """
  Documentation for KNN.
  """

  use Application

  import Supervisor.Spec

  require Logger

  alias KNN.Node.Command
  alias KNN.Node.Command.Apollo
  alias KNN.Node.Store

  def start(_type, _args) do
    Logger.debug "Starting node \"" <> System.get_env("NODE_NAME") <> "\" of type: \"" <> System.get_env("NODE_TYPE") <> "\""

    children = case System.get_env("NODE_TYPE") do
      "command" ->
        [
          worker(Command, [:command], [name: Command]),
          worker(Apollo, [:apollo], [name: Apollo])
        ]
      "store" ->
        [
          worker(Store, [[name: :knn_storage_server]])
        ]
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
