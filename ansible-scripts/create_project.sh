#!/bin/bash

PROJECT="$1"

if [ -z "${PROJECT}" ]
then
	read -r -p "Project name: " PROJECT
fi

mkdir "${PROJECT}" && cd "${PROJECT}"
mkdir playbooks remote_scripts retrieved_files source_files
touch "playbooks/.gitkeep" "remote_scripts/.gitkeep" "retrieved_files/.gitkeep" "source_files/.gitkeep" "run.sh"
