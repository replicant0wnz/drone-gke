#!/bin/bash

GCLOUD='/google-cloud-sdk/bin/gcloud'

if [[ -z "$NAMESPACE" ]]
then
    NAMESPACE="default"
fi

# Decode key
echo $GKE_BASE64_KEY | base64 -d - > /gcloud.json

# Set project
PROJECT=`cat /gcloud.json | jq -r .project_id`
if [[ $DEBUG == "True" ]]
then
    $GCLOUD config set project $PROJECT
else
    $GCLOUD config set project $PROJECT > /dev/null 2>&1
fi

if [[ $? == 0 ]]
then
    echo "Project set to : $PROJECT"
else
    echo "Unable to set project: $PROJECT"
    exit 1
fi

# Auth with JSON key
if [[ $DEBUG == "True" ]]
then
    $GCLOUD auth activate-service-account --key-file /gcloud.json 
else
    $GCLOUD auth activate-service-account --key-file /gcloud.json > /dev/null 2>&1
fi
if [[ $? == 0 ]]
then
    echo "JSON auth      : Success"
else
    echo "Unable to auth"
    exit 1 
fi

# Set cluster
if [[ $DEBUG == "True" ]]
then
    $GCLOUD container clusters get-credentials $CLUSTER --zone $ZONE
else
    $GCLOUD container clusters get-credentials $CLUSTER --zone $ZONE > /dev/null 2>&1 
fi
if [ $? == 0 ]
then
    echo "Cluster set to : $CLUSTER"
    echo "Zone set to    : $ZONE"
else
    echo "Unable to set zone: $ZONE or cluster: $CLUSTER"
    exit 1 
fi

# Execute command to auth once
if [[ $DEBUG == "True" ]]
then
    /kubectl get pods
else
    /kubectl get pods > /dev/null 2>&1
fi

IFS=',' read -r -a DEPLOYMENTS <<< "$DEPLOYMENT_NAME"
IFS=',' read -r -a CONTAINERS <<< "$CONTAINER_NAME"

for DEPLOY in "$DEPLOYMENTS[@]"
do
    for CONTAINER in "$CONTAINERS[@]"
    do
        /kubectl -n $NAMESPACE set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$CONTAINER_IMAGE:$CONTAINER_TAG 
    done
done
