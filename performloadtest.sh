#!/bin/bash

ingress=$1

num_parallel_threads=$2

requests_per_thread=$3

ids=$(curl -sS "$1/cats/findFirst?limit=$requests_per_thread" | jq -r '.[].cat_data | fromjson | .id')
ids_array=($ids)
echo "${ids_array[@]}"

echo 'id'
loadtester.sh "$1/cats/findById?id=" "$2" "$3" "${ids_array[@]}"
echo 'attribute'
loadtester.sh "$1/cats/findByBreed?breed=Persian" "$2" "$3"
echo 'attribute in array'
loadtester.sh "$1/cats/findByVaccinationName?vaccinationName=Rabies" "$2" "$3"
echo 'attribute in object'
loadtester.sh "$1/cats/findByAttributeFur?fur=short" "$2" "$3"
echo 'date'
loadtester.sh "$1/cats/findByVaccinationDate?date=2023-01-10" "$2" "$3"
# echo 'text search'
# loadtester.sh "$1/cats/fullTextSearchAttributes?search=short" "$2" "$3"
echo 'like with pattern'
loadtester.sh "$1/cats/findByNamePattern?pattern=%25xd%25" "$2" "$3"
