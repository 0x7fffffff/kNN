

# @relation iris
# @attribute SepalLength real [4.3, 7.9]
# @attribute SepalWidth real [2.0, 4.4]
# @attribute PetalLength real [1.0, 6.9]
# @attribute PetalWidth real [0.1, 2.5]
# @attribute Class {Iris-setosa, Iris-versicolor, Iris-virginica}
# @inputs SepalLength, SepalWidth, PetalLength, PetalWidth
# @outputs Class

defmodule KNN.Helper.KeelAttribute do
	defstruct [:name, :inner_data_type, :data]

	# This is sloppy, but it should work for our test data.
	@spec parse(String.t) :: __MODULE__
	def parse(line) do
		opts = line
		|> String.trim
		|> String.split
		|> Enum.reduce(%{}, fn(component, acc) -> 
			component = component |> String.trim

			if Map.has_key? acc, :name do
				{collection_type, items} = parse_collection component

				if collection_type do
					Map.put acc, :data, {collection_type, items}
				else
					data_type = get_data_type component

					if data_type do
						Map.put acc, :inner_date_type, data_type
					else
						# Need to build in error checking, this can crash.
						acc
					end
				end
			else
				Map.put acc, :name, component
			end
		end)

		struct __MODULE__, opts
	end

	@spec parse_collection(String.t) :: {:range | :set | nil, [any]}
	defp parse_collection(str) do
		cond do
		  String.starts_with?(str, "[") and String.ends_with?(str, "]") ->
				{:range, split_collection str}
			String.starts_with?(str, "{") and String.ends_with?(str, "}") ->
				{:set, split_collection str}
			true ->
				{nil, []}
		end
	end

	@spec split_collection(String.t) :: [any]
	defp split_collection(str) do
  	str
  	|> String.trim_leading("[")
  	|> String.trim_trailing("]")
  	|> String.split(", ")
	end

	@spec get_data_type(String.t) :: :number | :binary | nil
	defp get_data_type(str) do
		case str do
		  "real" ->
		  	:number
		  "string" ->
		  	:binary
		  _ ->
		  	nil
		end
	end
end

defmodule KNN.Helper.KeelDataRow do
	@enforce_keys [:data_components]
	defstruct [:data_components]
end

defmodule KNN.Helper.KeelDataset do
	# @enforce_keys [:relation, :attributes, :input_attributes, :output_attributes]
	@enforce_keys [:valid]
	defstruct [:relation, :attributes, :input_attributes, :output_attributes, :valid]

	alias KNN.Helper.KeelDataset, as: Dataset
	alias KNN.Helper.KeelDataRow, as: Row
	alias KNN.Helper.KeelAttribute, as: Attribute

	require Logger

	@spec parse_header(__MODULE__, String.t) :: __MODULE__
	def parse_header(dataset, "@relation" <> line) do
		line = line |> String.trim_leading
		%{dataset | relation: line}
	end

	@spec parse_header(__MODULE__, String.t) :: __MODULE__
	def parse_header(dataset, "@attribute" <> line) do
		attribute = line 
		|> String.trim_leading
		|> Attribute.parse

		attributes = if dataset.attributes do
			dataset.attributes ++ [attribute]
		else
			[attribute]
		end

		%{dataset | attributes: attributes}
	end

	@spec parse_header(__MODULE__, String.t) :: __MODULE__
	def parse_header(dataset, "@inputs" <> line) do
		components = line 
		|> String.trim_leading
		|> String.split

		%{dataset | input_attributes: components}
	end

	@spec parse_header(__MODULE__, String.t) :: __MODULE__
	def parse_header(dataset, "@outputs" <> line) do
		components = line 
		|> String.trim_leading
		|> String.split

		%{dataset | output_attributes: components}
	end

	@spec parse_header(__MODULE__, any) :: __MODULE__
	def parse_header(dataset, _), do: dataset

	@spec recheck_validity(__MODULE__) :: __MODULE__ | :error
	def recheck_validity(dataset), do: dataset

	@spec parse(String.t, (({Dataset, Row} | :error) -> none)) :: none
	def parse(path, handler) do
		path
		|> File.stream!([:read_ahead, :utf8], :line)
		|> Stream.with_index
		|> Stream.transform(%__MODULE__{valid: false}, fn({line, index}, acc) -> 
			line = line |> String.trim

			if String.starts_with?(line, "@") do
				result = acc 
				|> __MODULE__.parse_header(line)

				case result do
				  :error ->
						{:halt, acc}
					acc ->
						Logger.warn inspect line
						Logger.warn inspect acc

						{[line], acc}
				end
			else
				result = if acc.valid do
					acc
				else
					acc |> __MODULE__.recheck_validity
				end

				case result do
				  :error ->
						handler.(:error)
						{:halt, acc}
					acc ->
						Logger.warn inspect line
						Logger.warn inspect acc

						handler.({acc, line})
						{[line], acc}				    
				end
			end
		end)
		|> Stream.run
	end
end

defmodule KNN.Helper.KeelParser do
	alias KNN.Helper.KeelDataset, as: Dataset
	alias KNN.Helper.KeelDataRow, as: Row

	@spec parse_from_file(String.t, (({Dataset, Row} | :error) -> none)) :: none
	def parse_from_file(path, handler) do
		# passing this off for now
		Dataset.parse path, handler
	end
end

# defmodule KNN.Helper.KeelParser do
# 	use GenStage

# 	require Logger

# 	alias KNN.Helper.KeelHeader, as: Header

# 	def init(path) do
# 		Logger.warn "keel parser producer init"
# 		# do initial parsing here, and pass off a KeelDataset
# 		{:producer, path}	
# 	end

# 	def handle_demand(demand, path) when demand > 0 do
# 		Logger.warn demand
# 		Logger.warn path

# 		# events = Enum.to_list(counter..counter+demand-1)
# 		{:noreply, ["test event"], ""}
# 	end

# 	def parse() do
		
# 	end
# end

defmodule KNN.Helper.KeelParserProducerConsumer do
	use GenStage

	require Logger

	def init(number) do
		Logger.error "keel producer/consumer init"
		{:producer_consumer, number}
	end

	def handle_events(events, _from, payload) do
		Logger.error "keel product/consumer received event: #{payload}"

    {:noreply, ["test event"], payload}
   end
end

defmodule KNN.Helper.TestConsumer do
	use GenStage

	require Logger

	def init(:ok) do
		{:consumer, :the_state_does_not_matter}
	end

	def handle_events(events, _from, state) do
		:timer.sleep(1000)

		Logger.info inspect events

		{:noreply, [], state}
	end
end
