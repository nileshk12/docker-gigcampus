#!/bin/sh
host="$1"
port="$2"
shift 2
cmd="$@"

while ! nc -z "$host" "$port"; do
    sleep 1
done

exec $cmd