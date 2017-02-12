# @relation iris
# @attribute SepalLength real [4.3, 7.9]
# @attribute SepalWidth real [2.0, 4.4]
# @attribute PetalLength real [1.0, 6.9]
# @attribute PetalWidth real [0.1, 2.5]
# @attribute Class {Iris-setosa, Iris-versicolor, Iris-virginica}
# @inputs SepalLength, SepalWidth, PetalLength, PetalWidth
# @outputs Class

defmodule KNN.Helper.KeelAttribute do
	@valid_outer_data_type [:range, :set]
	@valid_inner_data_type [:real, :binary]

	@enforce_keys [:name, :inner_data_type]
	defstruct [:name, :inner_data_type, :outer_data_type] 

	@spec parse(String.t) :: __MODULE__
	def parse(line) do
		components = line |> String.split
		# %__MODULE__{

		# }
	end
end

defmodule KNN.Helper.KeelHeader do

	@enforce_keys [:attribute, :value]
	defstruct [:attribute, :value]

  # @spec add(number, number) :: {number, String.t}
  # def add(x, y), do: {x + y, "You need a calculator to do that?!"}

  @spec isHeader(String.t) :: boolean
	def isHeader(line) when not is_nil(line) do
		
	end
	def isHeader(_), do: false

	@spec parse(String.t) :: __MODULE__
	def parse(line) when not is_nil(line) do
		
	end
	def parse(_), do: nil
end

defmodule KNN.Helper.KeelDataRow do
	
end

defmodule KNN.Helper.KeelDataset do
	alias KNN.Helper.KeelDataRow, as: Row

	@spec parse(String.t, ((Row) -> nil)) :: nil
	def parse(path, completion) do
		
	end
end


defmodule KNN.Helper.KeelParser do
	use GenStage

	alias KNN.Helper.KeelHeader, as: Header

	def init(path) do
		{:producer, path}	
	end

	def handle_demand(demand, counter) when demand > 0 do
		events = Enum.to_list(counter..counter+demand-1)
		{:noreply, events, counter + demand}
	end

	def parse() do
		
	end
end

defmodule KNN.Helper.KeelParserProducerConsumer do
	use GenStage

	def init(number) do
		{:producer_consumer, number}
	end

	def handle_events(events, _from, number) do
    events =
      for event <- events,
          entry <- event..event+number,
          do: entry
    {:noreply, events, number}
   end
end

defmodule KNN.Helper.TestConsumer do
	use GenStage

	def init(:ok) do
		{:consumer, :the_state_does_not_matter}
	end

	def handle_events(events, _from, state) do
		:timer.sleep(1000)

		IO.inspect events

		{:noreply, [], state}
	end
end
