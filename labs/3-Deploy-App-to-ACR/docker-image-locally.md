## Build the Docker Image Locally

The application can be built & ran locally as below once you are in the app directory

``` bash
cd app
docker build -t devopsjourneyapp .
```

Or, if the above doesn't work:

     ```bash
     docker build --platform=linux/amd64 -t thomasthorntoncloud .
     ```

> 🔍 **Note**: The --platform option specifies the target platform as linux/amd64, useful for multi-platform images.


The `-t` is for the tag (the name) of the Docker image and the `.` is telling the Docker CLI that the Dockerfile is in the current directory

After the Docker image is created, run the following command to confirm the Docker image is on your machine.
`docker image ls`

```bash
thomas 3-Deploy-App-to-ACR % docker image ls
REPOSITORY                                   TAG       IMAGE ID       CREATED          SIZE
devopsjourneyapp                             latest    0bc7e236870f   21 seconds ago   137MB
```

## Run The Docker Image Locally
Now that the Docker image is created, you can run the container locally just to confirm it'll work and not crash.

1. To run the Docker container, run the following command:
`docker run -tid devopsjourneyapp`

- `t` stands for a TTY console
- `i` stands for interactive
- `d` stands for detach so your terminal isn't directly connected to the Docker container

2. To confirm the Docker container is running, run the following command:
`docker container ls`

You should now see the container running.

```bash
thomas 3-Deploy-App-to-ACR % docker container ls
CONTAINER ID   IMAGE              COMMAND           CREATED         STATUS         PORTS      NAMES
60d40a4a53bb   devopsjourneyapp   "python app.py"   5 seconds ago   Up 4 seconds   5000/tcp   unruffled_goldwasser
```

## 🧠 Knowledge Check

After creating and running the Docker image, consider these questions:
1. Why do we use the `-t` flag when building the Docker image?
2. What's the purpose of the `--platform` option in the build command?
3. How does running the container with `-tid` flags differ from running it without these flags?

## 🔍 Verification

To ensure the Docker image was created and is running successfully:
1. Check that the image appears in the output of `docker image ls`
2. Verify that the container is listed and in the "Up" state when you run `docker container ls`


## 💡 Pro Tip

Consider using Docker Compose for more complex applications with multiple services. It simplifies the process of running multi-container Docker applications.