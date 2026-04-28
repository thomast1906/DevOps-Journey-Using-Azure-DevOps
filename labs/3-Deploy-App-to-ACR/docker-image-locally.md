# 🐳 Build and Test the Docker Image Locally


## 🎯 Learning Objectives

By the end of this guide, you'll be able to:

- Build the Python/Flask Docker image locally — using `python:3.13-slim` as the base
- Run the container locally — and verify the application responds on port `5000`
- Understand the image structure — layers, base image, and exposed ports

> ⏱️ **Estimated Time**: ~10 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Docker Desktop** installed and running
- **`app/` folder** present (Flask app + Dockerfile)

---

## 🚀 Step-by-Step Implementation

### Step 1: Build the Docker Image

1. **📂 Navigate to the app directory**

   ```bash
   cd app
   ```

2. **🔨 Build the image**

   ```bash
   docker build -t devopsjourneyapp .
   ```

   If you are on an Apple Silicon (M-series) Mac and need a `linux/amd64` image (matching the AKS node architecture):

   ```bash
   docker build --platform=linux/amd64 -t devopsjourneyapp .
   ```

   > 💡 The `-t` flag sets the image name/tag. The `.` tells Docker the build context is the current directory (where `Dockerfile` lives).

   **✅ Expected Output:**
   ```
   [+] Building 12.3s (10/10) FINISHED
    => [internal] load build definition from Dockerfile
    => [1/5] FROM docker.io/library/python:3.13-slim
    => [2/5] WORKDIR /app
    => [3/5] COPY requirements.txt .
    => [4/5] RUN pip install --no-cache-dir -r requirements.txt
    => [5/5] COPY . .
    => exporting to image
    => => naming to docker.io/library/devopsjourneyapp:latest

   Successfully built 0bc7e236870f
   Successfully tagged devopsjourneyapp:latest
   ```

3. **📋 Confirm the image exists**

   ```bash
   docker image ls devopsjourneyapp
   ```

   **✅ Expected Output:**
   ```
   REPOSITORY         TAG       IMAGE ID       CREATED          SIZE
   devopsjourneyapp   latest    0bc7e236870f   21 seconds ago   137MB
   ```

---

### Step 2: Run the Container Locally

1. **▶️ Start the container**

   ```bash
   docker run -d -p 5000:5000 --name devopsjourneyapp-test devopsjourneyapp
   ```

   Flags explained:
   - `-d` — detached mode (runs in background)
   - `-p 5000:5000` — maps host port 5000 to container port 5000
   - `--name` — gives the container a memorable name

2. **✅ Confirm the container is running**

   ```bash
   docker container ls --filter "name=devopsjourneyapp-test"
   ```

   **✅ Expected Output:**
   ```
   CONTAINER ID   IMAGE              COMMAND           CREATED        STATUS        PORTS                    NAMES
   60d40a4a53bb   devopsjourneyapp   "python app.py"   5 seconds ago  Up 4 seconds  0.0.0.0:5000->5000/tcp   devopsjourneyapp-test
   ```

---

### Step 3: Test the Application

1. **🌐 Test via curl**

   ```bash
   curl http://localhost:5000
   ```

   **✅ Expected Output:**
   ```html
   <!DOCTYPE html>
   <html>
   <head><title>DevOps Journey App</title></head>
   <body>
     <h1>Welcome to the DevOps Journey App!</h1>
     ...
   </body>
   </html>
   ```

2. **🖥️ Or open in your browser**

   Navigate to [http://localhost:5000](http://localhost:5000) — you should see the Flask application homepage.

---

### Step 4: Review Container Logs

```bash
docker logs devopsjourneyapp-test
```

**✅ Expected Output:**
```
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.17.0.2:5000
Press CTRL+C to quit
```

---

### Step 5: Stop and Clean Up

```bash
# Stop the running container
docker stop devopsjourneyapp-test

# Remove the container
docker rm devopsjourneyapp-test
```

---

## ✅ Validation

**Local validation:**
- Image appears in `docker image ls` with the correct tag
- Container starts without errors
- `curl http://localhost:5000` returns an HTML response
- `docker logs` shows Flask startup messages with no errors

**Full validation script:**
```bash
#!/bin/bash
echo "=== Building Docker image ==="
docker build -t devopsjourneyapp . && echo "✅ Build successful"

echo ""
echo "=== Starting container ==="
docker run -d -p 5000:5000 --name devopsjourneyapp-test devopsjourneyapp
sleep 3

echo ""
echo "=== Testing HTTP response ==="
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000)
if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ HTTP 200 received — app is running correctly"
else
  echo "❌ Unexpected HTTP code: $HTTP_CODE"
fi

echo ""
echo "=== Cleaning up ==="
docker stop devopsjourneyapp-test && docker rm devopsjourneyapp-test
echo "✅ Container stopped and removed"
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

**Common issues:**

```bash
# Problem: "port is already allocated" — port 5000 in use
# Solution: Stop the conflicting container or use a different host port
docker stop $(docker ps -q --filter "publish=5000")
# Or map to a different port:
docker run -d -p 5001:5000 --name devopsjourneyapp-test devopsjourneyapp
curl http://localhost:5001

# Problem: Build fails with "pip install" errors
# Solution: Ensure requirements.txt exists and lists correct packages
cat app/requirements.txt
# Expected to include: flask, azure-monitor-opentelemetry==1.8.7

# Problem: Container exits immediately after starting
# Solution: Check logs for Python errors
docker logs devopsjourneyapp-test
# Common cause: syntax error in app.py or missing environment variable

# Problem: "manifest unknown" on Apple Silicon when building for linux/amd64
# Solution: Enable Docker Desktop Rosetta emulation or BuildKit
docker buildx build --platform=linux/amd64 -t devopsjourneyapp --load .

# Problem: curl shows connection refused
# Solution: Wait a few seconds for Flask to start, or check container is running
docker container ls --filter "name=devopsjourneyapp-test"
sleep 5 && curl http://localhost:5000
```

</details>

---

## 🔑 Key Takeaways

1. **`python:3.13-slim` reduces image size** — the slim variant strips non-essential OS packages, reducing the image from ~1GB to ~137MB. Smaller images pull faster in AKS and reduce the security attack surface.
2. **`--platform=linux/amd64` cross-compiles the image** for AMD64 architecture. On Apple Silicon (ARM64) Macs, Docker defaults to `linux/arm64`. AKS nodes run on AMD64, so the flag ensures the image is compatible with the cluster.
3. **`-d` runs detached** (background); **`-it` runs interactive** (attaches your terminal to stdin/stdout). Use `-d` for services you want running in the background, `-it` for debugging or shells.
4. **Application Insights is not configured locally** — `APPLICATIONINSIGHTS_CONNECTION_STRING` is injected by Kubernetes as a secret at runtime (via the `aikey` K8s secret). Locally, the `azure-monitor-opentelemetry` SDK detects the missing variable and disables telemetry gracefully.

---

## ➡️ What's Next

Your image builds and runs correctly locally. Head to the pipeline lab to push it to ACR via Azure DevOps.

**[← Back to Lab 3 Overview](./README.md)** | **[Continue to Lab 3.1 →](./1-Deploy-App-to-ACR.md)**

---

## 📚 Additional Resources

- 🔗 [Docker — Build your Python image](https://docs.docker.com/language/python/build-images/)
- 🔗 [Python 3.13 slim Docker image](https://hub.docker.com/_/python)
- 🔗 [Flask documentation](https://flask.palletsprojects.com/en/3.1.x/)
- 🔗 [azure-monitor-opentelemetry PyPI](https://pypi.org/project/azure-monitor-opentelemetry/)