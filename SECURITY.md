Autoren:
Christian Engelsberger und
Dennis Hermann


# A3 - Health checks

* **Readiness probe:** Determines whether a pod should receive traffic. If a pod is compromised (for example, an attacker crashes part of the app, injects malicious behavior, or disrupts dependencies), a properly designed readiness check can fail and signal Kubernetes to stop routing traffic to that pod. Without this, the compromised pod would continue serving requests, potentially exposing data, spreading malicious responses, or acting as a foothold for further attacks.

* **Liveness probe:** Detects when a container is in a bad or inconsistent state and restarts it automatically. If an attacker manages to put the application into a broken or stuck state (e.g., via resource exhaustion or exploiting a bug), liveness checks can limit how long that compromised state persists. While it doesn’t “fix” a vulnerability, it reduces the window of exploitation.
