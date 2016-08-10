#!/bin/bash
SONARQUBE_PLUGINS_LIST="sonarqube_plugins.list"
if [[ $(basename $0) != "download_sonarqube_plugins.sh" ]] ; then
  echo "Wrong way to execute download_sonarqube_plugins.sh"
  exit 1
fi
if [[ -f $SONARQUBE_PLUGINS_LIST ]] ; then
  test -d "SonarQubePlugins" || mkdir "SonarQubePlugins"
	while IFS= read -r plugin_line
	do
		cd "SonarQubePlugins"
    plugin=`echo $plugin_line | awk -F"|" '{ print $1 }'`
    plugin_version=`echo $plugin_line | awk -F"|" '{ print $2 }'`
    plugin_filename="sonar-"$plugin"-"$plugin_version".jar"
		URL="https://sonarsource.bintray.com/Distribution/sonar-"$plugin"-plugin/sonar-"$plugin"-plugin-"$plugin_version".jar"
	  wget -N $URL
		printf "%s\n" "$plugin plugin added!"
	done <"$SONARQUBE_PLUGINS_LIST"
fi
