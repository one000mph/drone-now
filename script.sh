#!/bin/sh
set -e

VERCEL_DEPLOY_OPTIONS=" --no-clipboard"
VERCEL_AUTH=""

# Get the token or error
if [ -z "$PLUGIN_VERCEL_TOKEN" ]; then
    # No explicit token provided, check for secret
    if [ -z "$VERCEL_TOKEN" ]; then
        echo "> Error!! either the parameter vercel_token or the secret VERCEL_TOKEN is required!"
        exit 1;
    else
        PLUGIN_VERCEL_TOKEN="$VERCEL_TOKEN"
    fi
fi

if [ -n "$PLUGIN_SCOPE" ]; then
    echo "> adding custom scope $PLUGIN_SCOPE"
    VERCEL_SCOPE_OPTION="--scope $PLUGIN_SCOPE"
else
    echo "> No custom scope provided."
fi

VERCEL_AUTH="$VERCEL_AUTH --token $PLUGIN_VERCEL_TOKEN $VERCEL_SCOPE_OPTION"

if [ -n "$PLUGIN_DIRECTORY" ]; then
    echo "> Deploying $PLUGIN_DIRECTORY on Vercel…"
fi

if [ -n "$PLUGIN_LOCAL_CONFIG" ]; then
    echo "> using local config called $PLUGIN_LOCAL_CONFIG"
    VERCEL_DEPLOY_OPTIONS="${VERCEL_DEPLOY_OPTIONS} -A ../$PLUGIN_LOCAL_CONFIG"
    VERCEL_DEPLOYMENT_URL=$(vercel $VERCEL_AUTH $VERCEL_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
    echo "> Success! Deployment complete to $VERCEL_DEPLOYMENT_URL";

    if [ -n "$PLUGIN_PROD" ]; then
        echo "> Production deploy…" &&
        PROD_SUCCESS_MESSAGE=$(vercel deploy --prod $VERCEL_AUTH $VERCEL_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
        echo "$PROD_SUCCESS_MESSAGE"
    fi
else
    echo "> No local config provided, vercel will not use a local config"

    if [ -n "$PLUGIN_DEPLOY_NAME" ]; then
        echo "> adding deploy_name $PLUGIN_DEPLOY_NAME"
        VERCEL_DEPLOY_OPTIONS="${VERCEL_DEPLOY_OPTIONS} --name $PLUGIN_DEPLOY_NAME"
    else
        echo "> No deployment name provided. The directory will be used as the name"
    fi

    VERCEL_DEPLOYMENT_URL=$(vercel $VERCEL_AUTH $VERCEL_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
    echo "> Success! Deployment complete to $VERCEL_DEPLOYMENT_URL";

    if [ -n "$PLUGIN_PROD" ]; then
        echo "> Production deploy…" &&
        PROD_SUCCESS_MESSAGE=$(vercel deploy --prod $VERCEL_AUTH $VERCEL_DEPLOY_OPTIONS $PLUGIN_DIRECTORY) &&
        echo "$PROD_SUCCESS_MESSAGE"
        ## Check exit code
        rc=$?;
        if [[ $rc != 0 ]]; then
            echo "> non-zero exit code $rc" &&
            exit $rc
        fi
    fi
fi


if [ "$PLUGIN_CLEANUP" == "true" ]; then
    if [ -n "$PLUGIN_PROD" ]; then
        echo "> Cleaning up old deployments…" &&
        PROD_SUCCESS_MESSAGE=$(vercel rm --safe --yes $VERCEL_AUTH $PLUGIN_PROD) &&
        echo "$PROD_SUCCESS_MESSAGE"
    else
        echo "> Warning!! You must set the prod parameter when using the cleanup parameter so that vercel knows which deployments to remove!"
    fi
fi

## Check exit code
rc=$?;
if [[ $rc != 0 ]]; then
    echo "> non-zero exit code $rc" &&
    exit $rc
else
    echo $'\n'"> Successfully deployed! $VERCEL_DEPLOYMENT_URL"$'\n'
fi
