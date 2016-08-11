#!/bin/bash
if [[ $(basename $0) != "sonarqube_service_setup.sh" ]] ; then
  echo "Wrong way to execute sonarqube_service_setup.sh"
  exit 1
fi
. ./const.sh
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
docker create --name sonarqube \
  --link sonarqube-mysql:mysql \
  -p 9000:9000 -p 9092:9092 \
  -v sonarqube-data:/opt/sonarqube/data \
  -v sonarqube-extensions:/opt/sonarqube/extensions \
  -e SONARQUBE_JDBC_USERNAME=sonarqube \
  -e SONARQUBE_JDBC_PASSWORD=wikitosonar \
  -e SONARQUBE_JDBC_URL='jdbc:mysql://mysql:3306/sonar?useUnicode=true&characterEncoding=utf8&useSSL=false' \
  $DOCKER_SONARQUBE
printf "SonarQube created!"

if [[ -f $SONARQUBE_PLUGINS_LIST ]] ; then
  test -d "SonarQubePlugins" || mkdir "SonarQubePlugins"
  cd "SonarQubePlugins"
	while IFS= read -r plugin_line
	do
    plugin=`echo $plugin_line | awk -F"|" '{ print $1 }'`
    plugin_version=`echo $plugin_line | awk -F"|" '{ print $2 }'`
    plugin_filename="sonar-"$plugin"-plugin-"$plugin_version".jar"
		URL="https://sonarsource.bintray.com/Distribution/sonar-"$plugin"-plugin/"$plugin_filename
	  wget -N $URL
    docker cp $plugin_filename sonarqube:/opt/sonarqube/extensions/plugins
		printf "%s\n" "$plugin plugin added!"
	done < ../"$SONARQUBE_PLUGINS_LIST"
  cd ..
  echo "Starting $DOCKER_SONARQUBE docker..."
  docker start $DOCKER_SONARQUBE
  echo "$DOCKER_SONARQUBE started!"
fi
while ! wget -O /dev/null $(docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' sonarqube):9000
do
  sleep 1
done
export RANDOM_PW=$(date +%s | sha256sum | base64 | head -c 16)
curl -u admin:admin --request POST 'localhost:9000/api/users/change_password' --data "login=admin&password=$RANDOM_PW&previousPassword=admin"
SETUP_TOKEN=$(curl -u admin:$RANDOM_PW --request POST 'localhost:9000/api/user_tokens/generate' --data 'login=admin&name=SetupManagement' | python3 -c 'import json,sys;obj=json.load(sys.stdin);print(obj["token"])')
curl -u $SETUP_TOKEN: --request POST 'localhost:9000/api/permissions/remove_group' --data 'groupName=anyone&permission=scan'
curl -u $SETUP_TOKEN: --request POST 'localhost:9000/api/permissions/remove_group' --data 'groupName=anyone&permission=provisioning'
curl -u $SETUP_TOKEN: --request POST 'localhost:9000/api/permissions/add_group' --data 'groupName=sonar-administrators&permission=scan'
echo "export RANDOM_PW=\"$RANDOM_PW\"" >> const.sh
