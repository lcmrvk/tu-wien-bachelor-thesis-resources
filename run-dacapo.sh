
#!/usr/bin/env bash

# https://github.com/dacapobench/dacapobench/tree/v2006-10-MR2/benchmarks

JAVA_EXEC="$1"
RESULTS_DIR="$2"
BENCHMARKS=( antlr bloat eclipse fop hsqldb jython luindex lusearch pmd xalan )


JVM_SETTINGS="-Xmx768m"
SPEC_SETTINGS="-converge -s large"

USAGE="$0 <name-of-java-executable> <results-dir>"

if [[ -z "$JAVA_EXEC" ]]
then
    echo "Usage: $USAGE"
    exit 1
fi

if [[ -z "$RESULTS_DIR" ]]
then
    echo "Usage: $USAGE"
    exit 1
fi

mkdir -p "${RESULTS_DIR}"
mkdir -p "${RESULTS_DIR}/out"
mkdir -p "${RESULTS_DIR}/res"


for benchmark in "${BENCHMARKS[@]}"
do
    for i in {1..15}
    do
        COMMAND="$JAVA_EXEC $JVM_SETTINGS -jar dacapo-2006-10-MR2.jar $SPEC_SETTINGS $benchmark 2>&1 | tee $RESULTS_DIR/out/$benchmark.i$i.out | grep PASSED > $RESULTS_DIR/res/$benchmark.i$i.txt"
        TIME="$(date +%T)"
        echo "$COMMAND [$TIME]"
        bash -c "$COMMAND"
    done
done
