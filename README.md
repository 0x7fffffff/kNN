# KNN

**TODO: Add description**

## Building

```bash
iex -S mix
```

## Running

```bash
./run.sh n1@127.0.0.1 nodeType
```
Arg1 is representative of the node name as defined in sys.config
Arg2 is the type of node. Can be on of `["command", "store", "mesh"]`


Hit `control+c` twice to stop iex

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kNN` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kNN, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kNN](https://hexdocs.pm/kNN).

