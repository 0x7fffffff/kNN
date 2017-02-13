defmodule KNN.Node.Store do
  use GenServer
  
  require Logger

	def start_link(args \\ []) do
		opts = [
			{:ets_table_name, :knn_data_store},
	    {:log_limit, 100_000}
    ]

		GenServer.start_link __MODULE__, opts, args
	end

	def exists?(record) do
		fetch(record) != nil
	end

  def fetch(record) do
    case get(record) do
      {:not_found} -> 
      	nil
      {:found, found_record} ->
      	found_record
    end
  end

  def upsert(record) do
    set(record)
  end

  defp get(record) do
    case GenServer.call :knn_storage_server, {:get, record} do
      [] -> {:not_found}
      [found_record] -> {:found, found_record}
    end
  end

  defp set(record) do
    GenServer.call :knn_storage_server, {:set, record}
  end

  # GenServer callbacks

  def handle_call({:get, record}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    found_record = :ets.lookup(ets_table_name, record)
    {:reply, found_record, state}
  end

  def handle_call({:set, record}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    true = :ets.insert(ets_table_name, record)
    {:reply, record, state}
  end

  # TODO figure out max size and limits/ make deletion a thing if a record needs to be deleted?

  def init(args) do
    Logger.info "Initializing kNN Storage Gen Server"

    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end
end
