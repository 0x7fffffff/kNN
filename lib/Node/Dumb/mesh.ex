defmodule KNN.Node.Mesh do
  use GenServer
  alias KNN.Node.Point, as: Point

  alias KNN.Structs.Bounds, as: Bounds
  alias KNN.Node.Store, as: Store

  # Client func
  def start_link(
    state = {
      bounds = %Bounds{},
      store_nodes
    }
  ) when
  # A couple of PID lists
  is_list(store_nodes) 
  do
      opts = [ {:log_limit, 100_000} ]
      GenServer.start_link(__MODULE__, opts, state)
  end

  def init(_args = {bounds, store_nodes, neighbor_list}) do 
    records = []
    s_bounds = {
      bounds.x_min,
      bounds.x_max,
      bounds.y_min,
      bounds.y_max,
    }
    for pid <- store_nodes do
      {:ok, added } = Store.get_for_cell(pid, s_bounds) 
      records = [ added | records ]
    end

    records = List.flatten(records)
    state = {bounds, records}
    {:ok, state}
  end

  # Get the kNN from this node, for this record
  def get_knn(pid, test_record, k) when is_integer(k) do
    GenServer.call(pid, {:get_knn, test_record, k})
  end

  def handle_call({:get_knn, test_record}, _from, state) do
    # TODO:
  end


  @spec local_knn(pos_integer, [Point, ...], [Point, ...]) :: [{Point, [Point]}, ...]
  defp local_knn(k, test_points, other_points) do
      Enum.map(test_points, 
        fn(test_point) ->
          nearest_neighbors = other_points
          |> Enum.sort(fn(p1, p2) -> 
              Point.distance(test_point, p1) < Point.distance(test_point, p2)
          end)
          |> Enum.take(k)

          {test_point, nearest_neighbors}
      end)
  end
end



defmodule KNN.Node.Point do
	alias KNN.Node.Point

	@enforce_keys [:x, :y]
	defstruct [:x, :y]

	@spec distance(Point, Point) :: float
	def distance(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
		dx = :math.pow abs(x1 - x2), 2.0
		dy = :math.pow abs(y1 - y2), 2.0

		:math.sqrt dx + dy
	end
end
