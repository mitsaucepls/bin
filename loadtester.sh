#!/bin/bash
# TODO parallel and sequential mode
# TODO time limit

url=$1
num_parallel_threads=$2
requests_per_thread=$3
variable_array=(${@:4})

total_requests=$(($num_parallel_threads * $requests_per_thread))
tempfile=$(mktemp)

function perform_requests() {
    for ((i=0; i<requests_per_thread; i++)); do
        current_url=$url
        if [ ${#variable_array[@]} -gt 0 ]; then
            current_url="${current_url}${variable_array[i % ${#variable_array[@]}]}"
        fi
        curl -s "$current_url" | jq -r '"\(.["Estimated Rows"]),\(.["Planning Time"]),\(.["Scan Type"]),\(.["Actual Rows"]),\(.["Execution Time"])"' >> $tempfile &
        if (( (i + 1) % num_parallel_threads == 0 )); then
            wait
        fi
    done
    wait
}

echo "Starting load test..."
for ((thread=0; thread<num_parallel_threads; thread++))
do
    perform_requests &
done

wait

echo "Load test completed."

awk -F, '{
    estimatedRowsSum += $1;
    planningTimeSum += $2;
    scanTypes[$3]++;
    actualRowsSum += $4;
    executionTimeSum += $5;
    count++
}
END {
    print "Total Estimated Rows: " estimatedRowsSum "\nAverage Planning Time (seconds): " planningTimeSum/count "\nTotal Actual Rows: " actualRowsSum "\nAverage Execution Time (seconds): " executionTimeSum/count;
    for (type in scanTypes) {
        print "Scan Type " type ": " scanTypes[type];
    }
}' $tempfile

rm $tempfile
