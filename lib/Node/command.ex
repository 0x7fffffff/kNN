defmodule KNN.Node.Command do
	use GenServer

	require Logger

	def start_link(parent_pid) do
		Logger.debug "Starting commander with args: #{inspect parent_pid}"
		GenServer.start_link __MODULE__, %{parent_pid: parent_pid}
	end

	def init(initial_state) do
		Logger.debug "Reached Command node init"

		start(initial_state[:parent_pid])
		{:ok, initial_state}
	end

	def handle_info(:start, initial_state) do
		Logger.debug "Reached Command node start"
		start(initial_state[:parent_pid])
		{:noreply, initial_state}
	end

	defp start(parent_pid) when is_pid(parent_pid) do
    # should probably move data path into ENV VAR
    path = "data/iris/iris.dat"

    KNN.Helper.KeelParser.parse_from_file path, fn(result) -> 
    	case result do
    	  {dataset, row} ->
    	  # 	Logger.warn "dataset: #{inspect dataset}"
		    	# Logger.warn "received record: #{inspect row}"
		    	# Logger.debug "Finished parsing dataset"
		    	nil
		    :error ->
		    	Logger.error "Parser failed"
    	end
    end
    # {:ok, a} = GenStage.start_link(KNN.Helper.KeelParser, path)
    # {:ok, b} = GenStage.start_link(KNN.Helper.KeelParserProducerConsumer, [])
    # {:ok, c} = GenStage.start_link(KNN.Helper.TestConsumer, :ok)

    # GenStage.sync_subscribe(b, to: a)
    # GenStage.sync_subscribe(c, to: b)

    # Process.sleep(:infinity)
	end
end
