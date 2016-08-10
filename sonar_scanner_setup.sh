#!/bin/bash
if [[ $(basename $0) != "sonar_scanner_setup.sh" ]] ; then
  echo "Wrong way to execute sonar_scanner_setup.sh"
  exit 1
fi
wget -N "https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-2.6.1.zip"
unzip sonar-scanner-2.6.1.zip
PATH=$PATH:$(pwd)/sonar-scanner-2.6.1/bin
rm -rf sonar-scanner-2.6.1.zip
cd sonar-scanner-2.6.1/conf
rm -rf sonar-scanner.properties
cat <<EOF > sonar-scanner.properties
#----- Default SonarQube server
sonar.host.url=http://localhost:9000

#----- Default source code encoding
sonar.sourceEncoding=UTF-8

#----- MySQL
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&amp;characterEncoding=utf8&amp;useSSL=false
EOF
cd ..
cd ..
if [[ -f $PROJECTS_LIST ]] ; then
	while IFS= read -r project
	do
    cd "ProjectToBeAnalyzed/"$project
    cat <<EOF > sonar-project.properties
sonar.projectKey=$project
sonar.projectName=$project
sonar.projectVersion=0.1.0
sonar.sources=.
EOF
		printf "%s\n" "$project configuration file created!"
    sonar-scanner
    cd ..
    cd ..
	done <"$PROJECTS_LIST"
fi
