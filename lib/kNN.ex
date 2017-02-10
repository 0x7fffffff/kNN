defmodule KNN do
  @moduledoc """
  Documentation for KNN.
  """

  use Application

  require Logger

  def start(_type, _args) do
    Logger.warn "Starting node \"" <> System.get_env("NODE_NAME") <> "\" of type: \"" <> System.get_env("NODE_TYPE") <> "\""
    children = case System.get_env("NODE_TYPE") do
      "command" ->
        []
      "store" ->
        []
      "mesh" ->
        []
    end

    opts = [strategy: :one_for_one, name: KNN.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
