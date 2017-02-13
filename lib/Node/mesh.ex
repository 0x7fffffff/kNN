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

defmodule KNN.Node.Mesh do
	alias KNN.Node.Point

	@spec local_knn(pos_integer, [Point, ...], [Point, ...]) :: [{Point, [Point]}, ...]
	def local_knn(k, test_points, other_points) do
		test_points |> Enum.map(fn(test_point) ->
			nearest_neighbors = other_points
			|> Enum.sort(fn(p1, p2) -> 
				Point.distance(test_point, p1) < Point.distance(test_point, p2)
			end)
			|> Enum.take(k)

			{test_point, nearest_neighbors}
		end)
	end
end
