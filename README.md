# Drone-now

![Now logo](now.png?raw=true "now.sh")

Use case examples:

- Automatically create staging deployments for pull requests
- Automatically deploy and alias upon pushes to master

## Usage

For the usage information and a listing of the available options please take a look at [the docs](DOCS.md).

There are two ways to deploy.

### From docker

Deploy the working directory to now.

```bash
docker run --rm \
  -e NOW_TOKEN=xxxxxxx \
  -e PLUGIN_DEPLOY_NAME=my-deployment-name \
  -e PLUGIN_ALIAS=my-deployment-alias.now.sh \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  one000mph/drone-now
```

### From Drone CI

```yaml
pipeline:
  now:
    image: one000mph/drone-now
    deploy_name: my-deployment-name
    type: static
    scope: xxxxxxxx
    directory: public
    alias: my.deployment.com
    secrets: [ now_token ]
```
