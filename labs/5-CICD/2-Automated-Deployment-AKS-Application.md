# ♻️ Automated Rolling Deployments to AKS


## 🎯 **Learning Objectives**

By the end of this lab, you will:
- [ ] **Switch the image tag from `$(Build.BuildId)` to `latest`** — enabling the pipeline to always use the most recent build
- [ ] **Add `imagePullPolicy: Always`** — forcing AKS to pull the latest image on every pod restart or rolling update
- [ ] **Understand zero-downtime rolling updates** — how Kubernetes replaces pods without service interruption
- [ ] **Verify the automated deployment** — by observing new pods running the `latest` image after a pipeline run

## 📋 **Prerequisites**

**✅ Required Knowledge:**
- [ ] Kubernetes Deployment and rolling update concepts
- [ ] Docker image tagging strategies

**🔧 Required Tools:**
- [ ] `kubectl` installed and configured (AKS credentials from Lab 4)

**🏗️ Infrastructure Dependencies:**
- [ ] Completed [Lab 5.1 — CI/CD Trigger](./1-Introduce-CI-CD-to-your-Pipeline.md)
- [ ] Application successfully deployed to AKS (Lab 4)

---

## 🚀 **Step-by-Step Implementation**

### **Step 1: Understand the Problem with Hardcoded Build IDs**

In Lab 4, the `app.yaml` had a hardcoded image tag:

```yaml
image: devopsjourneyoct2024acr.azurecr.io/repository:626
```

**Problems with this approach:**
- Every new pipeline run produces a new tag (`627`, `628`, ...) but the manifest still references `626`
- To update the running pods, you had to manually delete the Deployment and re-run the pipeline
- No zero-downtime rolling update — the old pods are torn down before new ones are ready
- Not truly automated — human intervention required for every deployment

---

### **Step 2: Update `app.yaml` to Use `latest` Tag**

1. **📝 Open the Kubernetes manifest**

   Open [`labs/5-CICD/pipelines/scripts/app.yaml`](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/5-CICD/pipelines/scripts/app.yaml#L19-L20)

2. **✏️ Update the image reference**

   Change:
   ```yaml
   image: devopsjourneyoct2024acr.azurecr.io/repository:626
   ```

   To:
   ```yaml
   image: devopsjourneyoct2024acr.azurecr.io/repository:latest
   imagePullPolicy: Always
   ```

   **`imagePullPolicy` options explained:**
   | Value | Behaviour |
   |-------|-----------|
   | `IfNotPresent` | Only pull if not cached locally — may run stale images |
   | `Always` | Always query the registry and pull if the digest has changed — **use for CI/CD** |
   | `Never` | Never pull — only uses locally cached images; fails if not cached |

   > 💡 `imagePullPolicy: Always` combined with the `latest` tag ensures every pod restart pulls the newest image from ACR. This enables truly automated rolling updates — no manifest changes needed per pipeline run.

---

### **Step 3: Update the Pipeline Tag to `latest`**

1. **📝 Open the pipeline YAML**

   Open [`labs/5-CICD/pipelines/lab5pipeline.yaml`](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/5-CICD/pipelines/lab5pipeline.yaml#L108)

2. **✏️ Change the Docker build tag**

   Find the Docker task and change the `tags` parameter:

   From:
   ```yaml
   tags: $(Build.BuildId)
   ```

   To:
   ```yaml
   tags: 'latest'
   ```

   This tells the `Docker@2` task to push the image to ACR with the `latest` tag, which is what the `app.yaml` now references.

---

### **Step 4: Commit, Push, and Verify**

1. **💾 Commit all changes**

   ```bash
   git add pipelines/lab5pipeline.yaml pipelines/scripts/app.yaml
   git commit -m "Switch to latest tag with imagePullPolicy Always for automated CI/CD"
   git push origin main
   ```

2. **⚡ The CI trigger fires automatically**

   The push to `main` triggers the pipeline (from Lab 5.1). Watch the pipeline run in Azure DevOps.

3. **🔍 Verify the `latest` tag in ACR**

   After the Build stage completes:

   ```bash
   az acr repository show-tags \
     --name devopsjourneyoct2024acr \
     --repository repository \
     --orderby time_desc \
     --top 3 -o table
   ```

   **✅ Expected Output:**
   ```
   Result
   ------
   latest
   ```


4. **🔍 Verify new pods are running the `latest` image**

   After the Deploy stage completes:

   ```bash
   kubectl describe pod \
     $(kubectl get pods -n thomasthorntoncloud -o jsonpath='{.items[0].metadata.name}') \
     -n thomasthorntoncloud \
     | grep Image:
   ```

   **✅ Expected Output:**
   ```
   Image: devopsjourneyoct2024acr.azurecr.io/repository:latest
   ```

---

## ✅ **Validation Steps**

**🔍 Deployment Validation:**
- [ ] `app.yaml` uses `latest` tag and `imagePullPolicy: Always`
- [ ] Pipeline YAML uses `tags: 'latest'`
- [ ] ACR shows `latest` tag after pipeline run
- [ ] AKS pods show `repository:latest` image
- [ ] Application still responds correctly via ALB FQDN

**🔧 Full Validation Script:**
```bash
#!/bin/bash
echo "=== Checking ACR for latest tag ==="
az acr repository show-tags \
  --name devopsjourneyoct2024acr \
  --repository repository \
  --orderby time_desc --top 3 -o table

echo ""
echo "=== Checking AKS pod image ==="
POD=$(kubectl get pods -n thomasthorntoncloud -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$POD" -n thomasthorntoncloud | grep "Image:"

echo ""
echo "=== Testing application availability ==="
FQDN=$(kubectl get gateway gateway-01 -n thomasthorntoncloud \
  -o jsonpath='{.status.addresses[0].value}')
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$FQDN")
echo "HTTP Status: $HTTP_CODE"
[ "$HTTP_CODE" = "200" ] && echo "✅ Application is healthy" || echo "❌ Application check failed"
```

---

## 🚨 **Troubleshooting Guide**

**❌ Common Issues:**

```bash
# Problem: Pods still running the old image tag after pipeline runs
# Solution: Verify imagePullPolicy is set to Always in app.yaml
kubectl get deployment -n thomasthorntoncloud -o yaml | grep -A2 imagePullPolicy

# Problem: ACR still shows old tag, not "latest"
# Solution: Confirm the pipeline tag was updated to 'latest' (not $(Build.BuildId))
grep "tags:" pipelines/lab5pipeline.yaml

# Problem: Rolling update causes brief downtime
# Solution: Ensure the Deployment has a readiness probe configured
# With readiness probes, Kubernetes waits for new pods to be ready before terminating old ones
kubectl describe deployment -n thomasthorntoncloud | grep -A5 "Readiness"

# Problem: "ErrImagePull" in pods after tag change
# Solution: Verify the WIF service principal has AcrPull role
az role assignment list \
  --scope "$(az acr show --name devopsjourneyoct2024acr --query id -o tsv)" \
  --query "[].{Principal:principalName,Role:roleDefinitionName}" -o table
```

---

## 💡 **Knowledge Check**

**🎯 Questions:**
1. Why does changing from `$(Build.BuildId)` to `latest` enable automated deployments?
2. What would happen if `imagePullPolicy` were left as `IfNotPresent` with the `latest` tag?
3. How does Kubernetes perform a rolling update with zero downtime?
4. What are the trade-offs of using `latest` in production vs. explicit version tags?

**📝 Answers:**
1. **The manifest no longer needs to change per build** — with `latest`, every `kubectl apply` references the same image name. With `imagePullPolicy: Always`, AKS pulls the updated image from ACR every time a pod is (re)started. The rolling update replaces old pods with new ones automatically, pulling the fresh `latest` image each time — no manifest update required.
2. **`IfNotPresent` with `latest` would serve stale images** — Kubernetes checks if the image is cached locally first. Since `latest` was already pulled once, it would reuse the cached version even though ACR now has a newer image under the same tag. `Always` bypasses the local cache and always fetches from the registry.
3. **Rolling update process**: (1) Kubernetes creates one (or more) new pods with the updated spec; (2) waits until the new pods pass the `readiness` probe; (3) terminates one (or more) old pods; (4) repeats until all replicas are replaced. Traffic is never fully interrupted because old pods serve requests while new pods warm up.
4. **`latest` is convenient for CI/CD** but provides less traceability and makes rollbacks harder (you cannot pin to a specific build). **Explicit version tags** (e.g., `626`) are better for production — you know exactly which build is running, can roll back by changing the tag, and can audit changes. A common pattern: use `latest` + BuildId in CI pipelines and promote explicit tags to production.

---

## 🎯 **Next Steps**

**✅ Upon Completion:**
- [ ] `app.yaml` updated: `image: ...repository:latest` + `imagePullPolicy: Always`
- [ ] Pipeline updated: `tags: 'latest'`
- [ ] Push to `main` triggers automatic pipeline run
- [ ] New pods running `repository:latest` confirmed in AKS

**➡️ Continue to:** [Lab 6 — Application Insights Monitoring](../6-Monitoring-and-Alerting/1-Application-Insights.md)

---

## 📚 **Additional Resources**

- 🔗 [Kubernetes — Rolling update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment)
- 🔗 [Kubernetes — Image pull policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy)
- 🔗 [ACR — Best practices for tagging](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-image-tag-version)
- 🔗 [Azure DevOps — Docker task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/docker-v2)

