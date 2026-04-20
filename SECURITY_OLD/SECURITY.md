Autoren:
Christian Engelsberger und
Dennis Hermann

# Dependency Trust Audit

Actions von GitHub werden nicht aufgelistet, da sie first-party sind.
List every third-party GitHub Action your pipeline uses. For each one:

## Who maintains it? Is it from a verified organization?

* aquasecurity/trivy-action -> Aqua Security (verified)
* docker/setup-qemu-action -> Docker (verified)
* docker/setup-buildx-action -> Docker (verified)
* docker/login-action -> Docker (verified)
* docker/build-push-action -> Docker (verified)
* golangci/golangci-lint-action	-> GolangCI (verified)
* hadolint/hadolint-action -> Haskell Dockerfile Linter (not verified)

## Are you pinning to a SHA or a mutable tag (like  `@v3`)? What is the risk of tag-based pinning? (Hint: research the  `tj-actions/changed-files`  incident from 2025 or the  `actions/checkout`  supply chain discussions)

* aquasecurity/trivy-action -> TAG@0.35.0
* docker/setup-qemu-action -> TAG@v3
* docker/setup-buildx-action -> TAG@v3
* docker/login-action -> TAG@v3
* docker/build-push-action -> TAG@v5
* golangci/golangci-lint-action	-> TAG@v7
* hadolint/hadolint-action -> TAG@v3.1.0

Bei Tags werden die Actions nicht auf einem festen Commit ausgeführt, da sie veränderbar sind. Maintainer können neuen Code veröffentlichen, der womöglich nicht mehr wie gewollt funktioniert. Außerdem kann eine Kompromitierung erfolgen. Angreifer können hierdurch bösartigen Code einschleusen, der aufgrund der Benutzung von Tags automatisch in Workflows ausgeführt wird. Dies passierte unter anderm bei der Action tj-actions/changed-files im Jahr 2025.

## Change at least 2 actions to SHA-pinned versions and explain why

* golangci/golangci-lint-action -> SHA@9fae48acfc02a90574d7c304a1758ef9895495fa
* hadolint/hadolint-action -> SHA@54c9adbab1582c2ef04b2016b760714a4bfde3cf

SHAs sind festgelegte Commits, die nicht verändert werden können. Der Code wird genau auf dem Commit ausgeführt der spezifiziert wurde. Es können daher keine unerwarteten Änderungen auftreten. Supply-Chain-Risiken können dadurch reduziert werden. SHAs sind daher als sicherer anzusehen, im Gegensatz zu TAGs.

# Secrets Management

Answer the following questions:

## What secrets does your pipeline need? List them with their minimum required permissions

`${{ secrets.GITHUB_TOKEN }}`
Wird für Login zur GitHub Container Registry (GHCR) verwendet.
Benötigt minimal read/write-Berechtigung auf das aktuelle Repository.

## What is the blast radius if  `DOCKER_TOKEN`  is leaked from a CI log? How would you limit it?

Ein Angreifer kann mit einem geleakten `DOCKER_TOKEN` alle Docker-Images im zugehörigen Repository verändern.

Um das Risiko zu minimieren, können Tokens mit **Scope** erstellt werden. Diese Tokens gelten nur für das konkrete Repository und nicht global. Außerdem soll **least privilege** angewendet werden, sodass nur die notwendigen Rechte vergeben werden.

## Why does the pipeline use  `${{ secrets.GITHUB_TOKEN }}`  instead of a PAT? What's the security difference?

Wieso `${{ secrets.GITHUB_TOKEN }}` anstatt von PAT verwendet wird hat mehrere Gründe: Der Token existiert nur während der **Laufzeit** des Workflows, ein geleakter Token ist also nur kurz nutzbar. PAT kann unbegrenzt gültig sein. Der **Scope** des Tokens ist auf das aktuelle Repository begrenzt. Ein PAT kann hingegen, bei falscher Konfiguration, Zugriff auf mehrere Repositories haben. Schließlich wird der Token **automatisch** erstellt und erfordert keine weitere Konfiguration.

## How would you detect if someone exfiltrates secrets via a malicious PR?

Exfiltration kann beispielsweise durch ungewöhnliche Befehle oder Verbindungen zu externen Servern erkannt werden. Diese Aktivitäten sind in den CI-Logs ersichtlich und sollten regelmäßig überprüft werden. Zusätzlich können durch Code Reviews auffällige Änderungen entdeckt werden, welche auf eine Extraktion hindeuten. 

# Pipeline Hardening

Implement at least 3 of the following and explain your choices:

## Use  `--exit-code`  on Trivy to actually fail the build on HIGH/CRITICAL vulnerabilities (not just report)

Es wurde ein Trivy-Scan von Aquasec eingeführt. Wenn eine kritische oder hohe Schwachstelle identifiziert wurde, so wird der Workflow abgebrochen. Images werden nicht weiter gepusht, wodurch das Risiko von Exploits reduziert wird.

## Add SBOM (Software Bill of Materials) generation

Die Pipeline erzeugt eine SBOM mit Syft für jedes Container-Image. SBOM hilft, alle Abhängigkeiten und Lizenzen im Container zu identifizieren. Dadurch können Schwachstellen schneller erkannt und bewertet werden.

## Prevent the pipeline from running on forks without approval

Führt Job nur aus, wenn der PR aus dem eigenen Repository ist. Verhindert, dass bösartiger Code aus Forks automatisch Secrets oder kritische Aktionen in der Pipeline ausführt, insbesondere den `GITHUB_TOKEN`.

