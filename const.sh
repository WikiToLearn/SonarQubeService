#!/bin/bash
export DOCKER_SONARQUBE="sonarqube"
export DOCKER_SONARQUBE_VERSION="6.0"
export DOCKER_MYSQL="mysql"
export DOCKER_MYSQL_VERSION="5.7.14"
export SONARQUBE_PLUGINS_LIST="sonarqube_plugins.list"
export PROJECTS_LIST="projects.list"
if test -d "conf" && test -f "conf/random_pw.conf"; then
  cd "conf"
  random_pw=$(<random_pw.conf)
  export RANDOM_PW=$random_pw
  cd ..
fi
