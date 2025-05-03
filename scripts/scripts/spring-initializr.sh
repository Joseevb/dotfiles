#!/bin/bash

# Function to fetch dependencies dynamically
fetch_dependencies() {
    spring init --list | awk '/Supported dependencies/{flag=1;next}/^$/{flag=0}flag' | awk -F'|' '{print $2}' | sed 's/ //g' | grep -v "^$"
}

# Function to display a fuzzy finder for dependencies
select_dependencies() {
  local dependencies=("$@")
  # Use fzf with tmux and multi-select enabled
  # Track selected dependencies and show them in the preview
  local selected_dependencies=""
  selected_dependencies=$(echo "${dependencies[@]}" | tr ' ' '\n' | fzf --multi --tmux --prompt="Select dependencies: " \
    --preview="cat {+f}" \
    --preview-window=up:3:wrap)

  # Return selected dependencies
  echo "$selected_dependencies"
}

# Fetch dependencies dynamically
echo "Fetching available dependencies from Spring Initializr..."
ALL_DEPENDENCIES=($(fetch_dependencies))
if [ ${#ALL_DEPENDENCIES[@]} -eq 0 ]; then
  echo "Error: Unable to fetch dependencies. Please check your Spring Initializr setup."
  exit 1
fi

# Step-by-step prompts to gather inputs
read -rp "Enter project name: " PROJECT_NAME
read -rp "Enter group ID (e.g., com.example): " GROUP_ID
read -rp "Enter artifact name (default: $PROJECT_NAME): " ARTIFACT_NAME
ARTIFACT_NAME=${ARTIFACT_NAME:-$PROJECT_NAME}

read -rp "Enter Java version (default: 17): " JAVA_VERSION
JAVA_VERSION=${JAVA_VERSION:-17}

# Select build tool
PS3="Choose a build tool: "
select BUILD_TOOL in "maven" "gradle"; do
  if [[ -n "$BUILD_TOOL" ]]; then
    break
  fi
done

# If build tool is gradle, prompt for type
if [[ "$BUILD_TOOL" == "gradle" ]]; then
  PS3="Choose a Gradle project type: "
  select GRADLE_TYPE in "gradle-project" "gradle-project-kotlin"; do
    if [[ -n "$GRADLE_TYPE" ]]; then
      break
    fi
  done
  TYPE_FLAG="--type=$GRADLE_TYPE"
else
  TYPE_FLAG=""
fi

# Use fzf for dependency selection
SELECTED_DEPENDENCIES=$(select_dependencies "${ALL_DEPENDENCIES[@]}")

# Confirm choices
echo "---------------------------------------------"
echo "Project Name:       $PROJECT_NAME"
echo "Group ID:           $GROUP_ID"
echo "Artifact Name:      $ARTIFACT_NAME"
echo "Java Version:       $JAVA_VERSION"
echo "Build Tool:         $BUILD_TOOL"
[[ "$BUILD_TOOL" == "gradle" ]] && echo "Gradle Type:        $GRADLE_TYPE"
echo "Dependencies:       $SELECTED_DEPENDENCIES"
echo "---------------------------------------------"
read -rp "Is this correct? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "Aborted by user."
  exit 1
fi

# Run the spring init command
COMMAND="spring init -n=$PROJECT_NAME -g=$GROUP_ID -a=$ARTIFACT_NAME --build=$BUILD_TOOL $TYPE_FLAG -j=$JAVA_VERSION -d=$(echo "$SELECTED_DEPENDENCIES" | tr '\n' ',') $PROJECT_NAME"

echo "Running: $COMMAND"
eval "$COMMAND"

echo "Project created successfully!"

