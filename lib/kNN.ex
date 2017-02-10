defmodule KNN do
  @moduledoc """
  Documentation for KNN.
  """

  use Application

  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: KNN.Supervisor]
    Supervisor.start_link(children, opts)
  end


  @doc """
  Hello world.

  ## Examples

      iex> KNN.hello
      :world

  """
  def hello do
    :world
  end
end
