# Ironhack DevOps & Cloud Learning Workspace

This repository collects course exercises, infrastructure labs and project working copies from my DevOps / Cloud learning journey.

It is a **learning workspace**, not one deployable application. For a cleaner portfolio, the standalone repositories linked below are the preferred entry points for the main projects.

## Featured project repositories

| Project | Focus | Repository |
|---|---|---|
| 3-tier application | ASP.NET Core API, UI, PostgreSQL, Docker and Kubernetes | [3-tier-application](https://github.com/mavanirahul1996/3-tier-application) |
| Taskly | FastAPI, PostgreSQL, Redis, Docker Compose, Terraform and monitoring | [taskly](https://github.com/mavanirahul1996/taskly) |
| Spring PetClinic | Java, Maven, GitHub Actions and application deployment practice | [spring-petclinic-rahul](https://github.com/mavanirahul1996/spring-petclinic-rahul) |
| Voting application | Multi-service containers, Redis, PostgreSQL and Kubernetes practice | [Voting_app_project](https://github.com/mavanirahul1996/Voting_app_project) |
| CI/CD demo | Node.js, GitHub Actions and EC2 deployment learning | [first-cicd-pipeline](https://github.com/mavanirahul1996/first-cicd-pipeline) |
| Kubernetes monitoring | Prometheus, Grafana, Loki and Kubernetes | [k8s-monitoring-lab](https://github.com/mavanirahul1996/k8s-monitoring-lab) |
| Loki workshop | Grafana Loki, Alloy, Prometheus and log queries | [loki-workshop](https://github.com/mavanirahul1996/loki-workshop) |

## Workspace layout

- `3-tier-application/`, `spring-petclinic-rahul/`, `voting_app/`, `first-cicd-pipeline/`, `k8s-monitoring-lab/` and `loki-workshop/` contain project copies or lab material.
- `terraform-lab/`, `terraform_project/`, `tf-mod-reusable/`, `tf-module-lab/` and `eks-quick-terraform/` contain Terraform exercises.
- `ansible-roles-lab/`, `clout_formation/` and Kubernetes YAML files contain automation and infrastructure practice.
- `Course/`, `Exercies/` and other folders contain course notes and smaller exercises.

## How to use this repository

1. Start with one of the standalone project repositories in the table above.
2. Read that project's README before running commands.
3. Check cloud account, region, Kubernetes context and estimated costs before provisioning resources.
4. Never commit cloud credentials, private keys, populated `.env` files or production connection strings.
5. Treat old manifests and course examples as learning material until their configuration is reviewed.

## Portfolio note

For job applications, link to the standalone repositories rather than presenting this entire course workspace as one finished product. Each project README should describe what is implemented, what was tested, and what remains future work.
