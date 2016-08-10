#!/bin/bash
if [[ ! -f "const.sh" ]] ; then
  echo "[const] : The parent script is not running inside the directory that contains const.sh"
  echo -e "\e[31mFATAL ERROR \e[0m"
  exit 1
fi
export DOCKER_SONARQUBE="sonarqube"
export DOCKER_MYSQL="mysql"
export SONARQUBE_PLUGINS_LIST="sonarqube_plugins.list"
export PROJECTS_LIST="projects.list"
