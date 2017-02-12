defmodule KNN.Command do
	use GenServer

	require Logger

	def start_link do
		GenServer.start_link __MODULE__, %{}
	end

	def init(state) do
		Logger.debug "Reached Command node init"
		start()
		{:ok, state}
	end

	def handle_info(:start, state) do
		Logger.debug "Reached Command node start"
		start()
		{:noreply, state}
	end

	defp start do
    # should probably move data path into ENV VAR
    path = "data/iris/iris.dat"
    {:ok, a} = GenStage.start_link(KNN.Helper.KeelParser, 0)
    {:ok, b} = GenStage.start_link(KNN.Helper.KeelParserProducerConsumer, 2)
    {:ok, c} = GenStage.start_link(KNN.Helper.TestConsumer, :ok)

    GenStage.sync_subscribe(b, to: a)
    GenStage.sync_subscribe(c, to: b)

    Process.sleep(:infinity)
	end
end
