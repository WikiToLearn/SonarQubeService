#!/bin/bash
. ./const.sh
if [[ $(basename $0) != "sonarqube_service_setup.sh" ]] ; then
  echo "Wrong way to execute sonarqube_service_setup.sh"
  exit 1
fi
echo "** SonarQube Service Setup **"
printf "%s\n" "Pulling docker images..."
if ! docker pull $DOCKER_MYSQL ; then
	printf "%s\n" "Failed pull for '$DOCKER_MYSQL'"
fi
printf "%s\n" "'$DOCKER_MYSQL' pulled, inspecting..."
if ! docker inspect $DOCKER_MYSQL &> /dev/null ; then
	printf "%s\n" "Error downloading '$DOCKER_MYSQL' image. Check the connection and then restart the script!"
	exit 1
fi
if ! docker pull $DOCKER_SONARQUBE ; then
	printf "%s\n" "Failed pull for '$DOCKER_SONARQUBE'"
fi
printf "%s\n" "'$DOCKER_SONARQUBE' pulled, inspecting..."
if ! docker inspect $DOCKER_SONARQUBE &> /dev/null ; then
	printf "%s\n" "Error downloading '$DOCKER_SONARQUBE' image. Check the connection and then restart the script!"
	exit 1
fi
docker run --name sonarqube-mysql \
  -e MYSQL_ROOT_PASSWORD=wikitolearn \
  -e MYSQL_DATABASE=sonar \
  -e MYSQL_USER=sonarqube \
  -e MYSQL_PASSWORD=wikitosonar \
  -v sonarqube-mysql-var-lib-mysql:/var/lib/mysql \
  -d $DOCKER_MYSQL --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
while ! docker exec sonarqube-mysql mysql -uroot -pwikitolearn sonar -e "SELECT 1" &> /dev/null
  do
    printf "%s\n" "Waiting for mysql... (this can take some time, usually less then 1 minute)"
    sleep 1
  done
printf "MySQL started!"
docker run -d --name sonarqube \
  --link sonarqube-mysql:mysql \
  -p 9000:9000 -p 9092:9092 \
  -v sonarqube-data:/opt/sonarqube/data \
  -v sonarqube-extensions:/opt/sonarqube/extensions \
  -e SONARQUBE_JDBC_USERNAME=sonarqube \
  -e SONARQUBE_JDBC_PASSWORD=wikitosonar \
  -e SONARQUBE_JDBC_URL='jdbc:mysql://mysql:3306/sonar?useUnicode=true&characterEncoding=utf8&useSSL=false' \
  $DOCKER_SONARQUBE
printf "SonarQube started"
./install_sonarqube_plugins.sh
./pull_github_repos.sh
./sonar_scanner_setup.sh
#./analyze_projects.sh