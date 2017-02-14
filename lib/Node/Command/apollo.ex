defmodule KNN.Node.Command.Apollo do
	use GenServer

	require Logger

	def start_link(args) do
		Logger.debug "Starting apollo with args: #{args}"
		GenServer.start_link __MODULE__, %{}, name: __MODULE__
	end

	def reset, do: GenServer.call __MODULE__, :reset

	def init(_state) do
    store = %{
      timer: make_timer(),
      tracking: %{}
    }

    {:ok, store}
  end

	def handle_call(:reset, _from, %{timer: timer, tracking: %{}}) do
		:erlang.cancel_timer timer

    store = %{
      timer: make_timer(),
      tracking: %{}
    }

		{:reply, :ok, store}
	end

  # Need a way of representing planar coordinates that each node represents. Each node should also track node type (store/mesh)
  # should split store/mesh node counts in roughly half
  # 

	def handle_info(:tick, %{tracking: %{} = tracking}) do
		# do stuff here
		Logger.debug "Tick"
    new_tracking = Node.list
    |> Enum.reduce(%{}, fn(node, acc) -> 
      acc |> Map.put(node, true)
    end)
    |> Map.merge(tracking)
      
		Logger.debug inspect new_tracking
		
    store = %{
      timer: make_timer(),
      tracking: new_tracking
    }

    {:noreply, store}
	end

  @spec assign_node_type(Node, %{required(Node) => atom}) :: atom
  defp assign_node_type(node, tracking) do
    
  end

	defp make_timer, do: Process.send_after self(), :tick, 5_000 # every 5 seconds
end
