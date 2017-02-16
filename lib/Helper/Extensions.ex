defmodule KNN.Helper.StringExt do
	def between(str, start_char, end_char) do
		result = with {front, _} <- :binary.match(str, start_char),
			{back, _} <- :binary.match(str, end_char) do
			{String.slice(str, (front + 1) .. (back - 1)), {front, back}}
		end

		case result do
		  :nomatch ->
		    {:error, nil}
		  {parsed_collection, range} ->
		  	{:ok, {parsed_collection, range}}
		end
	end
end