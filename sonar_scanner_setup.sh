#!/bin/bash
if [[ $(basename $0) != "sonar_scanner_setup.sh" ]] ; then
  echo "Wrong way to execute sonar_scanner_setup.sh"
  exit 1
fi
. ./const.sh

docker build -t wikitolearn/sonarqube-scanner docker-sonarqube-scanner

if [[ -f $PROJECTS_LIST ]] ; then
  test -d "ProjectToBeAnalyzed" || mkdir "ProjectToBeAnalyzed"
  cd "ProjectToBeAnalyzed"
  ProjectToBeAnalyzedDIR=$(pwd)
	while IFS= read -r project
	do
    cd $ProjectToBeAnalyzedDIR
		URL="https://github.com/"$project
		if test ! -d $project ; then
      mkdir -p $project
      rmdir $project
      git clone $URL $project
    fi
		cd $project
		git pull origin master
		git checkout master
		printf "%s\n" "$project pulled!"
	done <../"$PROJECTS_LIST"

  cd $ProjectToBeAnalyzedDIR

	while IFS= read -r project
	do
    cd $ProjectToBeAnalyzedDIR
    cd $project
    project_key=$(echo $project | sha256sum | awk '{ print $1 }')
    cat <<EOF > sonar-project.properties
sonar.host.url=http://sonarqube:9000
sonar.sourceEncoding=UTF-8
sonar.projectKey=$project_key
sonar.projectName=$project
sonar.projectVersion=0.1.0
sonar.sources=.
EOF
  	printf "%s\n" "$project configuration file created!"
    docker run --rm --link sonarqube:sonarcube --link sonarqube-mysql:mysql -v $(pwd):/root/src wikitolearn/sonarqube-scanner
  done <../"$PROJECTS_LIST"
fi
