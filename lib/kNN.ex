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
  alias KNN.Helper.KeelDataset

  def start(_type, _args) do
    Logger.debug "Starting node \"" <> System.get_env("NODE_NAME") <> "\" of type: \"" <> System.get_env("NODE_TYPE") <> "\""

    children = case System.get_env("NODE_TYPE") do
      "command" ->
        Logger.debug "received command type"
        [
          worker(Command, [self()], [name: Command]),
          worker(Apollo, [self()], [name: Apollo])
        ]
      "store" ->
        Logger.debug "received store type"
        [
          worker(Store, [[name: :knn_storage_server]])
        ]
      "mesh" ->
        Logger.debug "received mesh type"
        []
    end

    # TODO: Investigate different supervision strategies, and try to pick ones that
    # are good fits for the individual child processes.
    # https://hexdocs.pm/elixir/Supervisor.html#module-strategies
    #
    opts = [strategy: :one_for_one, name: KNN.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec receive_data(%KeelDataset{}, %{}) :: none
  def receive_data(dataset, row) do
    
  end
end
