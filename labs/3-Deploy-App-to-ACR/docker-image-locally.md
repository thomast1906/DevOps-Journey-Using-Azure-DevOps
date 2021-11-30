## Build & run the Docker Image Locally
The application can be built & ran locally as below once you are in this directory using Docker Compose. Docker Compose can be used to automate building container images and the deployment of multi-container applications.
`docker-compose up -d`

When completed, use the docker images command to see the created images. Three images have been downloaded or created. The azure-vote-front image contains the front-end application and uses the nginx-flask image as a base. The redis image is used to start a Redis instance.

Run the docker ps command to see the running containers:

`$ docker ps

CONTAINER ID        IMAGE                                             COMMAND                  CREATED             STATUS              PORTS                           NAMES
d10e5244f237        mcr.microsoft.com/azuredocs/azure-vote-front:v1   "/entrypoint.sh /sta…"   3 minutes ago       Up 3 minutes        443/tcp, 0.0.0.0:8080->80/tcp   azure-vote-front
21574cb38c1f        mcr.microsoft.com/oss/bitnami/redis:6.0.8         "/opt/bitnami/script…"   3 minutes ago       Up 3 minutes        0.0.0.0:6379->6379/tcp          azure-vote-back`

To see the running application, enter http://localhost:8080 in a local web browser. The sample application loads, as shown in the following example:

![](images/deploy-app-to-acr-4.png)

Stop and remove the container instances and resources with the docker-compose down command:

`docker-compose down`