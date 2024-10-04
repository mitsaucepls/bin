#!/bin/bash

# Define the path to the values.yaml file
DEFAULT_VALUES_FILE="./values.yaml"
DEFAULT_ENV_FILE="./.env"

VALUES_FILE="${1:-$DEFAULT_VALUES_FILE}"
ENV_FILE="${2:-$DEFAULT_ENV_FILE}"

# Function to update YAML file using a key and value pair
update_yaml() {
    local key="$1"
    local value="$2"

    # Convert underscores to dots and lowercase (e.g., HEY_I_HAVE_PARENTS -> hey.i.have.parents)
    yaml_path=$(echo "$key" | tr '_' '.')

    # Use yq to update the value in the YAML file
    yq eval ".${yaml_path} = \"$value\"" -i "$VALUES_FILE"
}

# Source the .env file to load environment variables
if [ -f "$ENV_FILE" ]; then
    # Read the .env file line by line
    while IFS='=' read -r key value; do
        # Ignore lines that are comments or empty
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

        # Remove potential leading/trailing spaces from the key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Export each variable to the environment
        export "$key=$value"

        # Update the values.yaml file
        update_yaml "$key" "$value"

    done < "$ENV_FILE"
else
    echo ".env file not found!"
    exit 1
fi

echo "values.yaml updated with environment variables."

