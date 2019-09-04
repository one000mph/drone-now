#!/bin/sh
set -e

NOW_DEPLOY_OPTIONS=" --no-clipboard"
NOW_AUTH=""

# Get the token or error
if [ -z "$PLUGIN_NOW_TOKEN" ]; then
    # No explicit token provided, check for secret
    if [ -z "$NOW_TOKEN" ]; then
        echo "> Error!! either the parameter now_token or the secret NOW_TOKEN is required!"
        exit 1;
    else
        PLUGIN_NOW_TOKEN="$NOW_TOKEN"
    fi
fi

if [ -n "$PLUGIN_SCOPE" ]; then
    echo "> adding custom scope $PLUGIN_SCOPE"
    NOW_SCOPE_OPTION="--scope $PLUGIN_SCOPE"
else
    echo "> No custom scope provided."
fi

NOW_AUTH="$NOW_AUTH --token $PLUGIN_NOW_TOKEN $NOW_SCOPE_OPTION"

if [ -n "$PLUGIN_DIRECTORY" ]; then
    echo "> Deploying $PLUGIN_DIRECTORY on now.sh…"
fi

if [ -n "$PLUGIN_LOCAL_CONFIG" ]; then
    echo "> using local config called $PLUGIN_LOCAL_CONFIG"
    NOW_DEPLOY_OPTIONS="${NOW_DEPLOY_OPTIONS} -A ../$PLUGIN_LOCAL_CONFIG"
    NOW_DEPLOYMENT_URL=$(now $NOW_AUTH $NOW_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
    echo "> Success! Deployment complete to $NOW_DEPLOYMENT_URL";

    if [ -n "$PLUGIN_PROD" ]; then
        echo "> Production deploy…" &&
        PROD_SUCCESS_MESSAGE=$(now deploy --prod $NOW_AUTH $NOW_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
        echo "$PROD_SUCCESS_MESSAGE"
    fi
else
    echo "> No local config provided, now will not use a local config"

    if [ -n "$PLUGIN_DEPLOY_NAME" ]; then
        echo "> adding deploy_name $PLUGIN_DEPLOY_NAME"
        NOW_DEPLOY_OPTIONS="${NOW_DEPLOY_OPTIONS} --name $PLUGIN_DEPLOY_NAME"
    else
        echo "> No deployment name provided. The directory will be used as the name"
    fi

    NOW_DEPLOYMENT_URL=$(now $NOW_AUTH $NOW_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
    echo "> Success! Deployment complete to $NOW_DEPLOYMENT_URL";

    if [ -n "$PLUGIN_PROD" ]; then
        echo "> Production deploy…" &&
        PROD_SUCCESS_MESSAGE=$(now deploy --prod $NOW_AUTH $NOW_DEPLOY_OPTIONS $PLUGIN_DIRECTOR) &&
        echo "$PROD_SUCCESS_MESSAGE"
    fi
fi


if [ "$PLUGIN_CLEANUP" == "true" ]; then
    if [ -n "$PLUGIN_PROD" ]; then
        echo "> Cleaning up old deployments…" &&
        PROD_SUCCESS_MESSAGE=$(now rm --safe --yes $NOW_AUTH $PLUGIN_PROD) &&
        echo "$PROD_SUCCESS_MESSAGE"
    else
        echo "> Warning!! You must set the prod parameter when using the cleanup parameter so that now.sh knows which deployments to remove!"
    fi
fi

## Check exit code
rc=$?;
if [[ $rc != 0 ]]; then
    echo "> non-zero exit code $rc" &&
    exit $rc
else
    echo $'\n'"> Successfully deployed! $NOW_DEPLOYMENT_URL"$'\n'
fi
