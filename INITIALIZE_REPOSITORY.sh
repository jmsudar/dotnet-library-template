#!/usr/bin/env bash

set -u -o pipefail

# Check if the required argument (project name) is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME="$1"

# Fetch the remote repository URL from 'origin'
REPO_URL=$(git remote get-url origin)

# Check if the URL is retrieved successfully
if [ -z "$REPO_URL" ]; then
  echo "Error: Failed to retrieve repository URL from Git. Make sure you're in a Git repository and the 'origin' remote is set."
  exit 1
fi

# Format the namespace: replace dashes with dots and convert to lowercase if necessary
NAMESPACE="$(echo "$REPO_URL" | awk -F'/' '{print $(NF-1)}' | awk -F':' '{print $NF}').$(echo "$REPO_URL" | awk -F'/' '{print $NF}' | sed 's/\.git$//')"

echo "Replacing REPONAME with $NAMESPACE"

# Replace REPONAME in files
find . -type f -not -path "./.git/*" -exec sed -i "s/REPONAME/$NAMESPACE/g" {} +

echo "Renaming directories and files"

# Optional: Rename files or directories if needed
mv src/PROJECTNAME/PROJECTNAME.cs src/PROJECTNAME/"$PROJECT_NAME".cs
mv src/PROJECTNAME.Tests/PROJECTNAME.Test.cs src/PROJECTNAME.Tests/"$PROJECT_NAME".Test.cs
mv src/PROJECTNAME src/"$PROJECT_NAME"
mv src/PROJECTNAME.Tests src/"$PROJECT_NAME".Tests

echo "Initializiing .NET solution and project files"

# Create the main solution
dotnet new sln -n "$PROJECT_NAME"

# Create the source project
dotnet new classlib -n "$PROJECT_NAME" -o "src/$PROJECT_NAME"
dotnet sln "$PROJECT_NAME".sln add "src/$PROJECT_NAME/$PROJECT_NAME".csproj

# Create the test project
dotnet new mstest -n "${PROJECT_NAME}.Tests" -o "tests/${PROJECT_NAME}.Tests"
dotnet sln "$PROJECT_NAME".sln add "tests/${PROJECT_NAME}.Tests/${PROJECT_NAME}.Tests.csproj"

echo "Deleting initialization script"

# Self-delete the script
rm -- "$0"

echo "Setup completed and cleanup done."
