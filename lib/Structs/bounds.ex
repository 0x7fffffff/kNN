defmodule KNN.Structs.Bounds do

  @enforce_keys [:x_min, :x_max, :y_min, :y_max]

  defstruct [:x_min, :x_max, :y_min, :y_max]

  def new(x_min, x_max, y_min, y_max) when
    is_number(x_min)
    and is_number(x_max)
    and is_number(y_min)
    and is_number(y_max)
    do
      %__MODULE__{
        :x_min => x_min + 0.0,
        :x_max => x_max + 0.0,
        :y_min => y_min + 0.0,
        :y_max => y_max + 0.0
      }
  end

  def point_in(bounds = %__MODULE__{}, {x, y}) when is_float(x) and is_float(y) do
        x <= bounds.x_max
        and x >= bounds.x_min
        and y <= bounds.y_max
        and y >= bounds.y_min
  end
  
end
