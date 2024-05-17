#!/bin/bash
# TODO parallel and sequential mode
# TODO time limit

if [ ! $# -eq 3 ]; then
    echo "The program requires 3 arguments."
    exit 1
fi

url=$1

num_parallel_threads=$2

requests_per_thread=$3

variable_array=$4

total_requests=$(($num_parallel_threads * $requests_per_thread))

tempfile=$(mktemp)

function perform_requests() {
    for ((i=1; i<=requests_per_thread; i++)); do
        (( $variable_array > 0 )) && url="${url}${variable_array[i-1]"
        curl -s -w ",%{time_total},%{size_download},%{http_code}\n" $url >> $tempfile &
        (( $i % num_parallel_threads == 0 )) && wait
    done
}

echo "Starting load test..."
for ((thread=1; thread<=num_parallel_threads; thread++))
do
    (perform_requests) &
done

wait
echo "Load test completed."

awk -F, '{
    timeSum+=$1;
    responseTimeSum+=$2;
    sizeSum+=$3;
    count++
    httpCodes[$4]++
}
END {
print "Time (seconds): " timeSum "\nAverage Time (seconds): " timeSum/count "\nResponse Time (seconds): " responseTimeSum "\nAverage Response Time (seconds): " responseTimeSum/count "\nBytes: " sizeSum "\nAverage Size (bytes): " sizeSum/count
    for (code in httpCodes) {
        print "HTTP Code " code ": "httpCodes[code];
    }
}' $tempfile

rm $tempfile
