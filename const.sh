#!/bin/bash
ENV_PROPERTIES_FILE="env.properties"
if [[ -f $ENV_PROPERTIES_FILE ]] ; then
  while IFS= read -r property
  do
    export $property
  done < "$ENV_PROPERTIES_FILE"
fi
