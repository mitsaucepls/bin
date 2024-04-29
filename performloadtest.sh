#!/bin/bash

ingress=$1

num_parallel_threads=$2

requests_per_thread=$3

loadtester.sh "$1/cats/findByBreed?breed=Persian" "$2" "$3"
loadtester.sh "$1/cats/findByVaccinationName?vaccinationName=Rabies" "$2" "$3"
loadtester.sh "$1/cats/findByAttributeFur?fur=short" "$2" "$3"
loadtester.sh "$1/cats/findByVaccinationDate?date=2023-01-10" "$2" "$3"
loadtester.sh "$1/cats/fullTextSearchAttributes?search=short" "$2" "$3"
loadtester.sh "$1/cats/findByNamePattern?pattern=%xd%" "$2" "$3"
