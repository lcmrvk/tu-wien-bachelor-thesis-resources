#!/usr/bin/env bash

JAVA_EXEC="$1"
NUM_ITERATIONS="$2"
JVM_SETTINGS="-Xmx768m"
SPEC_SETTINGS="--iterations ${NUM_ITERATIONS}"
BENCHMARKS="mpegaudio scimark.fft.small scimark.lu.small scimark.sor.small scimark.sparse.small scimark.monte_carlo"

USAGE="$0 <name-of-java-executable> <num-iterations>"

if [[ -z "$JAVA_EXEC" ]]
then
    echo "Usage: $USAGE"
    exit 1
fi

if [[ -z "$NUM_ITERATIONS" ]]
then
    echo "Usage: $USAGE"
    exit 1
fi

COMMAND="$JAVA_EXEC $JVM_SETTINGS -jar SPECjvm2008.jar $SPEC_SETTINGS $BENCHMARKS"

echo "-------- RUNNING BENCHMARKS WITH COMMAND --------"
echo -e "$COMMAND\n\n"

$COMMAND
