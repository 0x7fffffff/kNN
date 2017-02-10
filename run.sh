#! /bin/bash

nodeName=$1
nodeType=$2

if [ -z "$1" ]; then
    nodeName = "n1@127.0.0.1"
fi


NODE_TYPE=$nodeType iex --name $nodeName --erl "-config sys.config" -S mix
