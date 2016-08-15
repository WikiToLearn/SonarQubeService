#!/bin/bash
if [[ $(basename $0) != "sonar_scanner_setup.sh" ]] ; then
  echo "Wrong way to execute sonar_scanner_setup.sh"
  exit 1
fi
cd $(dirname $(realpath $0))
. ./const.sh
docker build -t wikitolearn/sonarqube-scanner docker-sonarqube-scanner
cd ProjectToBeAnalyzed
ProjectToBeAnalyzedDIR=$(pwd)
for file in $(find $(pwd) -name sonar-project.properties);
do
  while IFS= read -r property
  do
    property_name=`echo $property | awk -F"=" '{ print $1 }'`
    if [[ "$property_name" = "sonar.projectName" ]] ; then
      project_name=`echo $property | awk -F"=" '{ print $2 }'`
      cd $project_name
    fi
    if [[ "$property_name" = "sonar.links.homepage" &&  ! -z "$project_name" ]] ; then
      url_repo=`echo $property | awk -F"=" '{ print $2 }'`
      if ! test -d "src"; then
        git clone $url_repo "src"
      fi
      cd "src"
      git pull origin master
      git checkout master
      cd ..
    fi
  done <$file
  project_key=$(echo $project_name | sha256sum | awk '{ print $1 }')
  grep -q -F "sonar.projectKey=$project_key" $file || echo sonar.projectKey=$project_key >> $file
  printf "%s\n" "$project_name configuration updated!"
  printf "%s\n" "Staring analisys..."
  while ! wget -O /dev/null $(docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' sonarqube):9000
  do
    sleep 1
  done
  docker run --rm --link sonarqube:sonarqube --link sonarqube-mysql:mysql -e SONAR_PASSWORD=$RANDOM_PW -v $(pwd):/root/src wikitolearn/sonarqube-scanner
  cd $ProjectToBeAnalyzedDIR
done
