defmodule KNN.Node.Command.Apollo do
	use GenServer

	require Logger

  alias KNN.Helper.EnumExt

	def start_link(args) do
		Logger.debug "Starting apollo with args: #{inspect args}"
		GenServer.start_link __MODULE__, %{}, name: __MODULE__
	end

	def reset, do: GenServer.call __MODULE__, :reset

	def init(_state) do
    store = %{
      timer: make_timer(),
      tracking: %{store_nodes: [], mesh_nodes: []}
    }

    {:ok, store}
  end

	def handle_call(:reset, _from, %{timer: timer, tracking: %{}}) do
		:erlang.cancel_timer timer

    store = %{
      timer: make_timer(),
      tracking: %{store_nodes: [], mesh_nodes: []}
    }

		{:reply, :ok, store}
	end

  # Need a way of representing planar coordinates that each node represents. Each node should also track node type (store/mesh)
  # should split store/mesh node counts in roughly half
  # 

	def handle_info(:tick, %{tracking: %{store_nodes: store_nodes, mesh_nodes: mesh_nodes}}) do
    new_nodes = Node.list
    |> Enum.reject(fn(node) -> 
      EnumExt.contains(store_nodes, node) 
        or EnumExt.contains(mesh_nodes, node)
    end)

    {store_nodes, mesh_nodes} = new_nodes
    |> Enum.reduce({store_nodes, mesh_nodes}, fn(node, {store_nodes, mesh_nodes}) -> 
      num_store = Enum.count store_nodes
      num_mesh = Enum.count mesh_nodes

      cond do
        num_mesh > num_store ->
          {store_nodes ++ [node], mesh_nodes}
        num_mesh < num_store or num_mesh == num_store ->
          {store_nodes, mesh_nodes ++ [node]}
      end      
    end)
		
    store = %{
      timer: make_timer(),
      tracking: %{store_nodes: store_nodes, mesh_nodes: mesh_nodes}
    }

    {:noreply, store}
	end

  @spec assign_node_type(Node, %{required(Node) => atom}) :: atom
  defp assign_node_type(node, tracking) do
    
  end

	defp make_timer, do: Process.send_after self(), :tick, 30_000 # every 30 seconds
end
