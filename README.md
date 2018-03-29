# Google Kubernetes Engine plugin for Drone
This plugin allows you to authenticate on a per project basis to the Google Kubernetes Engine.

The plugin also allows for variables to assigned in the **matrix** definition section for doing multi-regional deployments in "cleaner" fashion.

## Usage

Pipeline to update a deployment on one cluster. The **gke_base64_key** variable must be a base64 encoded copy of the Google Cloud Platforms JSON key. There is no need to set the project as it is pulled via the JSON key.

```yaml
  pipeline:
    deploy:
      image: viant/drone-gke
      deployment_name: goapp-test-server
      container_name: goapp-test
      container_image: gcr.io/my-project/goapp-test
      cluster: central
      zone: us-central1-a
      container_tag: 1.0.${DRONE_BUILD_NUMBER}
      secrets: [ gke_base64_key ]
```

To deploy to multiple clusters within the same project using the **matrix** definition section. 

```yaml
  matrix:
    DEPLOYMENT_NAME: goapp-test-server
    CONTAINER_NAME: goapp-test
    CONTAINER_IMAGE: gcr.io/my-project/goapp-test

  pipeline:
    deploy_east:
      image: viant/drone-gke
      cluster: east
      zone: us-east1-a
      container_tag: 1.0.${DRONE_BUILD_NUMBER}
      secrets: [ gke_base64_key ]

    deploy_west:
      image: viant/drone-gke
      cluster: west 
      zone: us-west1-a
      container_tag: 1.0.${DRONE_BUILD_NUMBER}
      secrets: [ gke_base64_key ]
```

Having issues? Try the debug mode for a bit more versobe output

```yaml
  pipeline:
    deploy:
      image: viant/drone-gke
      debug: True
```

By default it will not echo the gke_base64_key, if you want to display it during the debug use ```debug_base64: True``` along w/the debug var above.

## Resources

The actual deploy code was based on [honestbee/drone-kubernetes](https://github.com/honestbee/drone-kubernetes) so multiple deployments and multiple contains should work.
