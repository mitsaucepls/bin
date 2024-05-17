#!/bin/bash
# TODO parallel and sequential mode
# TODO time limit

# if [ ! $# -eq 3 ]; then
#     echo "The program requires 3 arguments."
#     exit 1
# fi

#!/bin/bash

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
        curl -s -w ",%{time_total},%{size_download},%{http_code}\n" $current_url >> $tempfile &
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
