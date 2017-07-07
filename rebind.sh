#!/bin/bash

if [[ ($1 == "rebind") || ($1 == "restart" ) ]]
then
  command=$1
  echo "# $command bound services"
else
  echo "USAGE: rebind.sh [rebind|restart] [service name (default all)]"
  exit 1
fi

if [ -z "$2" ]; then
  use_service_name=all
else
  use_service_name=$2
fi

if [[ "$(which jq)X" == "X" ]]; then
  echo "Please install jq"
  exit 1
fi
if [[ "$(which cf)X" == "X" ]]; then
  echo "Please install cf"
  exit 1
fi

service_bindings=$(cf curl /v2/service_bindings | jq -r -c .resources[])
for service_binding in $service_bindings; do
        binding_guid=$(echo $service_binding | jq -r .metadata.guid)
        app_url=$(echo $service_binding | jq -r .entity.app_url)
        app_name=$(cf curl $app_url | jq -r .entity.name)
        app_guid=$(cf curl $app_url | jq -r .metadata.guid)
        app_space_url=$(cf curl $app_url | jq -r .entity.space_url)
        service_instance_url=$(echo $service_binding | jq -r .entity.service_instance_url)
        service_instance_name=$(cf curl $service_instance_url | jq -r .entity.name)
        service_url=$(cf curl $service_instance_url | jq -r .entity.service_url)
        service_name=$(cf curl $service_url | jq -r .entity.label)
        echo "# Service_name $service_name , service_instance $service_instance_name " 
        if [[ ($use_service_name == "all") || ($use_service_name == $service_name) ]]; then
        
          space_name=$(cf curl $app_space_url | jq -r .entity.name)
          org_url=$(cf curl $app_space_url | jq -r .entity.organization_url)
          org_name=$(cf curl $org_url | jq -r .entity.name)

          if [[ ($command == "rebind") ]]; then
            echo "# Cycling binding on app $app_name from service $service_instance_name in $org_name/$space_name"
            recreation_command=("cf target -o $org_name -s $space_name; cf bs $app_name $service_instance_name")
            echo "cf curl -X DELETE \"/v2/apps/$app_guid/service_bindings/$binding_guid\"" || echo "Failed to unbind for some reason."
            echo "$recreation_command" 
#            eval $recreation_command
          fi
          if [[ ($command == "restart") ]]; then
            echo "# Restarting app $app_name bound to service $service_instance_name in $org_name/$space_name"
            recreation_command=("cf target -o $org_name -s $space_name; cf restart $app_name")
            echo "$recreation_command"
#           eval $recreation_command
          fi     
        fi
done

