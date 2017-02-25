#! /bin/bash

nodeName=$1
nodeType=$2

if [ -z "$1" ]; then
    nodeName = "n1@127.0.0.1"
fi

mix deps.get

DATA_PATH="data/iris/iris.dat" NODE_NAME=$nodeName NODE_TYPE=$nodeType iex --name $nodeName --erl "-config sys.config" -S mix
