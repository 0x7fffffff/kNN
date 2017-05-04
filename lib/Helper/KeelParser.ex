
defmodule KNN.Helper.KeelAttribute do
	defstruct [:name, :inner_data_type, :data] # data is {:collection_type, [item]}

	alias KNN.Helper.StringExt

	require Logger

	@spec parse_collection(String.t) :: {:ok, :range, tuple} | {:ok, :set, tuple} | :error
	defp parse_collection(line) do
		case StringExt.between(line, "{", "}") do
			{:ok, result} -> {:ok, :set, result}
			_ ->
				case StringExt.between(line, "[", "]") do
					{:ok, result} -> {:ok, :range, result}
					_ -> :error
				end
		end
	end

	# This is sloppy, but it should work for our test data.
	@spec parse(String.t) :: __MODULE__
	def parse(line) do
		line = String.trim(line)

		{collection, type, {_, end_index}} = case parse_collection line do
			{:ok, type, {parsed, range}} ->
				collection = parsed |> String.split(", ")

				{collection, type, range}
			:error ->
				end_index = line
				|> String.graphemes
				|> Enum.count

				{[], nil, {end_index, 0}}
		end

		components = line
		|> String.slice(0..end_index)
		|> String.split

		attribute = %__MODULE__{}

		[name | components] = components 
		attribute = if name do
			%{attribute | name: String.trim(name)}
		else
			attribute
		end

		[inner_data_type | components] = components
		inner_data_type = String.trim(inner_data_type) |> get_data_type

		attribute = if inner_data_type do
			%{attribute | inner_data_type: inner_data_type}
		else
			attribute
		end

		# set or range
		case type do
			nil ->
				attribute
			:set ->
				if inner_data_type && inner_data_type == :number do
					%{attribute | data: {type, Enum.map(collection, &String.to_float(&1))}}
				else
					%{attribute | data: {type, collection}}
				end
			:range ->
				if inner_data_type && inner_data_type == :number do
					mapped = Enum.map(collection, &String.to_float(&1))

					%{attribute | data: {type, {Enum.at(mapped, 0), Enum.at(mapped, 1)}}}
				else
					%{attribute | data: {type, collection}}
				end
		end
	end

	@spec get_data_type(String.t) :: :number | :binary | nil
	defp get_data_type(str) do
		case str do
			"real" -> :number
			"string" -> :binary
			_ -> nil
		end
	end
end

defmodule KNN.Helper.KeelDataset do
	@enforce_keys [:valid]
	defstruct [
      :relation,
      :attributes,
      :input_attributes,
      :output_attributes,
      :valid,
      lines_used: 0
    ]

	alias KNN.Helper.KeelDataset, as: Dataset
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
		|> String.split(", ")

		%{dataset | input_attributes: components}
	end

	@spec parse_header(__MODULE__, String.t) :: __MODULE__
	def parse_header(dataset, "@outputs" <> line) do
		components = line 
		|> String.trim_leading
		|> String.split

		%{dataset | output_attributes: components}
	end

		@spec parse_header(__MODULE__, String.t) :: __MODULE__
		def parse_header(dataset, "@data") do
			__MODULE__.recheck_validity(dataset)
		end

	@spec parse_header(__MODULE__, any) :: __MODULE__
	def parse_header(dataset, _), do: dataset

	@spec recheck_validity(__MODULE__) :: __MODULE__ | :error
	def recheck_validity(dataset) do
		if dataset.input_attributes && dataset.output_attributes && dataset.attributes do
			all = dataset.input_attributes ++ dataset.output_attributes

			valid = Enum.count(dataset.attributes) == Enum.count(dataset.input_attributes) + Enum.count(dataset.output_attributes)
				and Enum.all?(dataset.attributes, fn(attr) ->
					Enum.any?(all, fn(attr_name) ->
						attr.name == attr_name
					end)
			end)

			%{dataset | valid: valid}
		else
			dataset
		end
	end

	@spec parse_row_from_headers(__MODULE__, String.t) :: %{}
	def parse_row_from_headers(dataset, line) do
		values = line |> String.split(", ")

		dataset.attributes
		|> Enum.with_index
		|> Enum.reduce(%{}, fn({attr, index}, acc) -> 
			value = Enum.at values, index

			if value do
				if attr.inner_data_type && attr.inner_data_type == :number do
					Map.put acc, attr.name, String.to_float(value)
				else
					Map.put acc, attr.name, value
				end
			else
				acc
			end
		end)
	end

	@spec parse(String.t, (({Dataset, %{required(String.t) => any}} | :error) -> none)) :: none
	def parse(path, handler) do
		path
		|> File.stream!([:read_ahead, :utf8], :line)
		|> Stream.with_index
		|> Stream.transform(%__MODULE__{valid: false}, fn({line, index}, dataset) -> 
			line = line |> String.trim

			if String.starts_with?(line, "@") do
				result = parse_header(dataset, line)
                dataset = %{dataset | lines_used: dataset.lines_used + 1 }

				case result do
					:error ->
						handler.(:error)
						{:halt, dataset}
					dataset -> {[line], dataset}
				end
			else
				if dataset.valid do
					handler.({dataset, parse_row_from_headers(dataset, line), index - dataset.lines_used})
					{[line], dataset}
				else
					handler.(:error)
					{:halt, dataset}
				end
			end
		end)
		|> Stream.run
	end
end

defmodule KNN.Helper.KeelParser do
	alias KNN.Helper.KeelDataset, as: Dataset

	@spec parse_from_file(String.t, (({Dataset, %{required(String.t) => any}} | :error) -> none)) :: none
	def parse_from_file(path, handler) do
		# passing this off for now
		Dataset.parse path, handler
	end
end
