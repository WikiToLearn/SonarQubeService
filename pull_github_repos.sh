#!/bin/bash
PROJECT_LIST="project.list"
if [[ $(basename $0) != "pull_github_repos.sh" ]] ; then
  echo "Wrong way to execute pull_github_repos.sh"
  exit 1
fi
echo "Pulling projects from GitHub..."
if [[ -f $PROJECT_LIST ]] ; then
  test -d "ProjectToBeAnalized" || mkdir "ProjectToBeAnalized"
	while IFS= read -r project
	do
		cd "ProjectToBeAnalized"
		URL="https://github.com/WikiToLearn/"$project
		test -d $project || git clone $URL
		cd $project
		git pull origin master
		git checkout master
		cd ..
		printf "%s\n" "$project pulled!"
	done <"$PROJECT_LIST"
fi
