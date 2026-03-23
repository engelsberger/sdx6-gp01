Gruppe1
Christian und Dennis

# Container Security Checklist

## Runs as non-root user
Wird nicht umgesetzt. Der Container besitzt Root-Rechte.
Wenn ein Angreifer Zugriff auf den Container bekommt, so könnte er schädliche Aktionen mit Root-Rechten ausführen.

## Uses a minimal/distroless base image in the final stage
Als Image wird Alpine verwendet, ein kleines, aber nicht distroloses Image.
Mit dem Image werden zusätzliche Tools mitgeliefert, welche Angreifer für schädliche Aktionen missbrauchen können.

## No secrets baked into the image or layers
Es werden keine Geheimnisse offengelegt.
Ein Angreifer könnte sonst sensible Informationen aus dem Image extrahieren.

## Base image and dependencies are version-pinned (no `latest` tags)
Die Spezifizierung erfolgt version-pinned.
Das verhindert, dass Angreifer unerwartete latest-Image-Schwachstellen ausnutzen. Außerdem sind version-pinned Versionen stabiler.

## Uses `.dockerignore` to exclude sensitive files (`.env`, `.git`, private keys)
Nicht umgesetzt.
Ohne .dockerignore könnten sensible Dateien ins Image gelangen und ausgelesen werden.

## Multi-stage build doesn't leak build tools into the production image
Erfüllt.
Ohne Compiler und Paketmanager im finalen Image haben Angreifer weniger Angriffsfläche zur Ausführung schädlicher Aktionen.

# Attack Surface Analysis

## What is the minimal set of capabilities this container needs? Would you drop capabilities in production?
Es werden keine extra Features (capabilities) benötigt. Dieser Container funktioniert mit den Linux-Standardfeatures. In Produktion würden wir Features droppen. (Principle of Least Privilege)

## If an attacker gains code execution inside the container, what can they access? What limits their movement?
Ein Angreifer mit RCE hat Zugriff auf Environment Variables, Filesystem, Netzwerk, ... Hindern kann einen Angreifer:
* Möglichst wenig Features (Principle of Least Privilege, siehe oben)
* Keine Root-Rechte
* Netzwerkrichtlinien

## The database password is passed as an environment variable — what are the risks?
Ein Passwort via Environment Variables zu übergeben, hat ein paar Risiken: 
* Sichtbar für Prozesse im Container 
* env ist sichtbar via Container Inspection 
* Kann in Logs / Crashdumps auftauchen

## What alternatives exist?
* Docker secrets: Docker Swarm stellt Secrets als gemountete Dateien zur Verfügung
* Mounted secret files - Anwendung liest diese während des startens
* External secret manager, z.B.: AWS Secrets Manager, Google Secret Manager, ...

# Docker Bake

## Why multi-platform builds matter for supply chain security
Wenn man nur für eine Architektur baut, kann es passieren, dass Docker auf einem anderen System automatisch ein fremdes Image verwendet. Das ist unsicher, weil dieses Image manipuliert oder schädlich sein könnte.
