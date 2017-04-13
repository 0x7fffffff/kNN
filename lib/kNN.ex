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
    # New plan: Instead of launching each node based on ENV vars or w/e, 
    # just launch a pool of mesh PIDs based on the mesh size,
    # and a pool of test storage nodes
    # and a pool of train storage nodes

    # become("")
    # TODO: Figure out how to build a proper app here


  end

  defp mesh_pool_config(square_dim) do

  end

  defp storage_pool_config(num_node, storage_type) do
    
  end

  defp become(nodetype) do
    Logger.debug "Starting node \"" <> System.get_env("NODE_NAME") <> "\" of type: \"" <> System.get_env("NODE_TYPE") <> "\""
    type = case nodetype do
      "" -> System.get_env("NODE_TYPE")
      x -> x
    end

    result = case type do
      "command" ->
        Logger.debug "received command type"
        children = [
          Supervisor.Spec.worker(Command, [self()], [name: Command]),
          Supervisor.Spec.worker(Apollo, [self()], [name: Apollo])
        ]

        {:ok, children}
      "store" ->
        Logger.debug "received store type"
        children = [
          worker(Store, [[name: :knn_storage_server]])
        ]

        {:ok, children}
      "mesh" ->
        Logger.debug "received mesh type"
        {:ok, []}
      _ ->
        {:error, []}
    end

    case result do
      {:ok, children} ->
        # TODO: Investigate different supervision strategies, and try to pick ones that
        # are good fits for the individual child processes.
        # https://hexdocs.pm/elixir/Supervisor.html#module-strategies
        #
        opts = [strategy: :one_for_one, name: KNN.Supervisor]
        Supervisor.start_link(children, opts)
      {:error, _} ->
        Logger.error "Node type unspecified!"
        {:error, 1}
    end
  end

  @spec receive_data(%KeelDataset{}, %{}) :: none
  def receive_data(dataset, row) do
    
  end
end
