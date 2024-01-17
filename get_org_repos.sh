#!/usr/bin/env bash

# Set your GitHub organization and personal access token
ORG_NAME="ipni"
ACCESS_TOKEN=$(grep "GITHUB_TOKEN" .env | cut -f 2 -d "=")

# Set pagination variables
PAGE=1
PER_PAGE=100

# Function for making paginated API request
make_request() {
  curl -s -H "Authorization: token $ACCESS_TOKEN" "https://api.github.com/orgs/$ORG_NAME/repos?per_page=$PER_PAGE&page=$PAGE"
}

# Process results function
function process_results() {
  if [ $? -ne 0 ]; then
    echo "Error making API request"
    return 1
  fi

  repo_names=$(echo "$response" | jq -r '.[].name')

  for repo in $repo_names; do
    contributors_response=$(curl -s -H "Authorization: token $ACCESS_TOKEN" "https://api.github.com/repos/$ORG_NAME/$repo/contributors")

    # Check if the request was successful
    if [ $? -ne 0 ]; then
      echo "Error making API request for contributors in $repo repository"
      continue
    fi

    # Parse contributor names from the JSON response and get the top 
    top_contributors=$(echo "$contributors_response" | jq -r '.[0].login' | tr '\n' ',' | sed 's/,$//')

    # Print organization, repository, and top contributors
    echo "$ORG_NAME, $repo,  $top_contributors"
  done
}

# Print CSV header
echo "Organization, Repository, Top_Contributors"

# Initial request
response=$(make_request)

# Process initial page of results
process_results "$response"

# Paginate until no more results
while [ $? -eq 0 ]; do
  PAGE=$((PAGE+1))
  response=$(make_request)
  process_results "$response"
done
