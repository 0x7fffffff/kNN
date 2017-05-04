defmodule KNN.Node.Store do
  use GenServer
  
  require Logger

  # Client side stuff
  def start_link({initial_records, x_attr, y_attr}) when
    is_binary(x_attr)
    and is_binary(y_attr)
    and is_list(initial_records) do
      opts = [ {:log_limit, 100_000} ]
      GenServer.start_link(__MODULE__, opts, {initial_records, x_attr, y_attr})
  end

  # Get the data associated with 
  def get_for_cell(pid, cell_bounds) do GenServer.call(pid, {:get_for_cell, cell_bounds}) end

  def add_record(pid, record) do GenServer.call(pid, {:append, record}) end

  # GenServer callbacks
  def handle_call({:append, new_record}, _from, {records, x_attr, y_attr}) do
    # Just append the new record at the head of the list
    {:reply, :ok, {[ new_record | records ], x_attr, y_attr}}
  end

  # Handle get_for_cell calls 
  def handle_call({:get_for_cell, bounds = {xMin, xMax, yMin, yMax}}, _from, state = {records, x_attr, y_attr}) when
    is_float(xMax) and is_float(yMax) and is_float(xMin) and is_float(yMin) do
    { 
      :reply,
      get_records_for_cell(bounds, records, x_attr, y_attr), #Reply content
      state # State doesn't change
    }
  end

  defp get_records_for_cell(bounds, records, x_attr, y_attr) do
    { xMin, xMax, yMin, yMax } = bounds
    records |> Enum.filter(fn(r) ->
        r[x_attr] <= xMax 
        and r[x_attr] >= xMin 
        and r[y_attr] <= yMax 
        and r[y_attr] >= yMin 
    end)
  end

  def init(state = {_records, _x_attr, _y_attr}) do
    Logger.info "Initializing kNN Storage GenServer"
    {:ok, state}
  end
end
