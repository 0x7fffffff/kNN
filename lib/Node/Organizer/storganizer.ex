

defmodule KNN.Node.Storeganizer do
  use GenServer

  alias KNN.Node.Store as: Store

  defstruct [records: 0, storenodes: []], :x_attr, :y_attr]

  # Pushes a record to a subset of nodes
  def store_record(pid, record) do
    GenServer.call(pid, {:store_record, record})
  end

  # Gets the nodes so that they can be used to populate a mesh node
  def get_nodes(pid) do
    GenServer.call(pid, :get_nodes)
  end

  def start_link(x_attr, y_attr) when is_binary(x_attr) and is_binary(y_attr)
  do
    GenServer.start_link(__MODULE__, %__MODULE__{
      x_attr: x_attr,
      y_attr: y_attr,
    })
  end

  def handle_call({:store_record, record}, _from, state) do

  end


end

