Autoren:
Christian Engelsberger und
Dennis Hermann

# A3 Health Checks

## Why health checks matter for security?

**Readiness probe:**  Determines whether a pod should receive traffic. If a pod is compromised (for example, an attacker crashes part of the app, injects malicious behavior, or disrupts dependencies), a properly designed readiness check can fail and signal Kubernetes to stop routing traffic to that pod. Without this, the compromised pod would continue serving requests, potentially exposing data, spreading malicious responses, or acting as a foothold for further attacks.

**Liveness probe:**  Detects when a container is in a bad or inconsistent state and restarts it automatically. If an attacker manages to put the application into a broken or stuck state (e.g., via resource exhaustion or exploiting a bug), liveness checks can limit how long that compromised state persists. While it doesn’t “fix” a vulnerability, it reduces the window of exploitation.

# B1 Production vs Development Values

## Document the difference between the production value file and the development value file. Why do they differ?
DEV = Entwicklungsumgebung
PROD = Produktionsumgebung

**securityContext**
In DEV sind die Sicherheitsrestriktionen bewusst gelockert, um Debugging und Entwicklung zu erleichtern. Dadurch lässt sich die Arbeit flexibler gestalten. In PROD werden hingegen strenge Sicherheitsrichtlinien angewendet, um die Angriffsfläche und Privilege Escalation zu minimieren.

**Resource limits**
In DEV werden häufig keine strikten Resource Limits gesetzt, um maximale Flexibilität zu ermöglichen. Dadurch können Anwendungen ohne künstliche Einschränkungen getestet und leichter debuggt werden. In PROD werden hingegen Resource Limits verwendet, um den stabilen Betrieb sicherzustellen. Limits verhindern, dass einzelne Pods übermäßig Ressourcen verbrauchen und dadurch andere Anwendungen oder den gesamten Cluster beeinträchtigen.

**Replica count**
In DEV wird nur eine Instanz verwendet, um das Debugging zu vereinfachen. In PROD werden hingegen mehrere Replikate eingesetzt, um Hochverfügbarkeit und Ausfallsicherheit zu gewährleisten.

**Image pull policy**
In DEV werden Images nur neu geladen, wenn sie lokal nicht vorhanden sind. Das soll einen beschleunigten Ablauf ermöglichen. In PROD hingegen wird das Image immer neu gezogen, um sicherzustellen, dass die aktuelle und freigegebene Version verwendet wird und keine veralteten oder unsicheren Images laufen.

**Ingress TLS configuration**
DEV ist auf Einfachheit und schnelle Tests ausgelegt, während PROD auf Sicherheit, Stabilität und Schutz sensibler Daten optimiert ist. In PROD wird TLS verwendet, um die Kommunikation zu verschlüsseln und Daten während der Übertragung zu schützen. 

**Credential Handling**
In DEV werden Datenbank-Zugangsdaten direkt in der values-Datei gespeichert. Dies ist akzeptabel, da keine produktiven oder sensiblen Daten verwendet werden und die Umgebung isoliert ist. In PROD dürfen Passwörter nicht direkt in der values-Datei gespeichert werden. Stattdessen sollten Kubernetes Secrets verwendet werden, um Zugangsdaten sicher zu verwalten und ungewollte Leaks zu vermeiden. In der aktuellen Konfiguration ist das Passwort leer und soll durch ein Kubernetes Secret zur Laufzeit gesetzt werden.

# B2 Helm Chart Security Audit

## Review insecure-chart/ and document the following: Every security issue you find , What attack each issue enables & How to fix it

**Exposed credentials**
Benutzer und Passwörter sind in values.yaml im Klartext gespeichert. Jeder der Zugang zu dem Repository hat, kann diese Daten einsehen. Ein Angreifer kann dadurch die Datenbank kompromittieren und auf dort gespeicherte Daten zugreifen. Um das zu verhindern, sollten sensible Daten in die secrets.yaml ausgelagert werden, anstatt sie direkt in values.yaml zu speichern.

**No resource limits defined**
Es wurden keine Systemressourcen festgelegt, welcher der Container einhalten muss. Dadurch darf der Container unbegrenzt Ressourcen verbrauchen. Ein Angreifer kann durch DDoS eine Überlastung verursachen. Dadurch können andere Dienste nicht mehr korrekt ausgeführt werden. Die Verfügbarkeit ist nicht gegeben. Um das zu verhindern, sollten klare Ressourcengrenzen festgelegt werden. Zum Beispiel cpu: "500m" oder memory: "512Mi".

**No security context**
Der Security Kontext ist nicht allzu detailliert ausgearbeitet. Es wurden keine konkreten Sicherheitsmaßnahmen definiert. Beispielsweise wird der Container als root ausgeführt, das heißt der Container verfügt standardmäßig über weitreichende Berechtigungen. Ein Angreifer der den Container kompromittiert hat dadurch sehr viel Kontrolle über die Umgebung. Um das zu verhindern, sollte der Security Kontext festgelegt werden. Zum Beispiel runAsNonRoot: true oder readOnlyRootFilesystem: true.

**No Ingress TLS**
TLS wurde nicht konfiguriert. Der Datenverkehr findet daher unverschlüsselt statt. Falls es dem Angreifer gelingt eine Man-in-the-middle Position einzunehmen, dann kann er den ganzen Datenverkehr im Klartext mitlesen beziehungsweise manipulieren. Um das zu verhinden, sollte TLS im Ingress aktiviert werden.

**No specific version pinning**
Das verwendete Container image nutzt einen "latest"-Tag. Das ist nicht ideal, da durch die Übernahme des Repositories, ein bösartiges Image deployed werden kann. Das ermöglicht Supply-Chain-Angriffe, alle die dieses Image als Dependancy nicht korrekt gepinnt haben sind anfällig. Angreifer können dadurch bösartigen Code ausführen. Um das zu verhindern, sollten spezifische Versionen mittels SHA gepinnt werden.

**No health probes**
Health probes wurden nicht implementiert. Dadurch kann Kubernetes nicht erkennen, ob Container noch funktionsfähig sind. Abgestürzte Container erhalten weiterhin Anfragen. Dadurch kann der Dienst instabil werden oder falsche Antworten liefern. Um das zu verhindern, sollten health probes implementiert werden. Beispielsweise in Form von liveness und readiness Checks.

# B3 Secrets in GitOps

## Why is it a problem to store Kubernetes Secrets (even base64-encoded) in Git?
Base64 ist keine Verschlüsselung, sondern nur eine einfache Kodierung, die leicht wieder zurück in Klartext umgewandelt werden kann.

## Research and compare at least 2 solutions: Sealed Secrets, SOPS, External Secrets Operator, Vault. Which would you choose for this project and why?
**Sealed Secrets** verschlüsselt Kubernetes Secrets mit einem clusterspezifischen öffentlichen Schlüssel. Die verschlüsselten Secrets können sicher in Git gespeichert werden und werden erst im Cluster entschlüsselt.  **SOPS** verschlüsselt Dateien (z. B. YAML oder JSON) mit Schlüsseln aus AWS KMS, oder PGP. **External Secrets Operator** verbindet Kubernetes mit externen Secret-Systemen wie AWS Secrets Manager, HashiCorp Vault oder Azure Key Vault. **Vault** ist ein spezialisiertes Secret-Management-System mit sehr hoher Sicherheit, dynamischen Secrets und detaillierter Zugriffskontrolle.

Für dieses Projekt würde ich den **External Secrets Operator** wählen. Secrets werden nicht im Git gespeichert, wodurch keine sensiblen Daten im Repository landen. Gleichzeitig lässt sich die Lösung gut in moderne Lösungen integrieren und unterstützt verschiedene Secret-Backends.
