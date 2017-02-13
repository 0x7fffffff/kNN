defmodule KNN.Node.Command.Apollo do
	use GenServer

	require Logger

	def start_link(args) do
		Logger.debug "Starting apollo with args: #{args}"
		GenServer.start_link __MODULE__, %{}, name: __MODULE__
	end

	def reset, do: GenServer.call __MODULE__, :reset

	def init(_state), do: {:ok, %{timer: make_timer()}}

	def handle_call(:reset, _from, %{timer: timer}) do
		:erlang.cancel_timer timer
		{:reply, :ok, %{timer: make_timer()}}
	end

	def handle_info(:tick, _state) do
		# do stuff here
		Logger.debug "Tick"
		Logger.debug inspect Node.list

		{:noreply, %{timer: make_timer()}}
	end

	defp make_timer, do: Process.send_after self(), :tick, 1_000 # every 30 seconds
end