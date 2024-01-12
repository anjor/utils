#!/usr/bin/env bash

# Set your GitHub organization and personal access token
ORG_NAME="filecoin-project"
ACCESS_TOKEN=$(cat .env | cut -f 2 -d "=")

# Make API request to get repositories
response=$(curl -s -H "Authorization: token $ACCESS_TOKEN" "https://api.github.com/orgs/$ORG_NAME/repos")

# Check if the request was successful
if [ $? -ne 0 ]; then
  echo "Error making API request"
  exit 1
fi

# Parse repository names from the JSON response
repo_names=$(echo "$response" | jq -r '.[].name')

# Print CSV header
echo "Organization, Repository, Top_Contributors"

# Loop through each repository and get top contributors
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

