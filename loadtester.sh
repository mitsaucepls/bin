#!/bin/bash

url=$1

num_parallel_threads=$2

requests_per_thread=$3

total_requests=$(($num_parallel_threads * $requests_per_thread))

tempfile=$(mktemp)
# echo "Starting load test: $total_requests requests to $url ($num_parallel_threads parallel threads, $requests_per_thread requests each)"
# (seq 1 $requests_per_thread | xargs -n1 -P$requests_per_thread curl -o /dev/null -s $url) &

function perform_requests {
    for ((i=1; i<=requests_per_thread; i++))
    do
        curl -o /dev/null -s -w "%{time_total},%{size_download}\n" $url >> $tempfile &
        if (( $i % num_parallel_threads == 0 )); then wait; fi
    done
}

echo "Starting load test..."
for ((thread=1; thread<=num_parallel_threads; thread++))
do
    (perform_requests) &
done

wait
echo "Load test completed."

awk -F, '{timeSum+=$1; sizeSum+=$2; count++} END {print "Average Time (seconds): " timeSum/count "\nAverage Size (bytes): " sizeSum/count}' $tempfile

rm $tempfile
