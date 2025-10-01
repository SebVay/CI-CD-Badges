# CI-CD-Badges

📛 A CI/CD–maintained repository that stores and exposes project metrics (such as code coverage) in a way that can be consumed by other repositories to generate **live badges** via [shields.io](https://shields.io/) and other custom metrics.

Example:

[![Jacoco](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/SebVay/CI-CD-Badges/refs/heads/main/Multi-Module-Report/badges/coverage.json)](https://sebvay.github.io/CI-CD-Badges/Multi-Module-Report/)

---

## 📖 What is this?
This is not a repository meant for direct development.
Instead, it acts as a **data source** for metrics:
- Whenever a change is merged into the `main` branch of one of my projects, a [Bitrise](https://www.bitrise.io/) workflow runs.
- That workflow, using [those scripts](https://github.com/SebVay/CI-CD-Badges/tree/main/ci), generates reports (e.g., code coverage, size metrics, etc.).
- The results are pushed here, in a consistent format.
- Other repositories can then point to those metrics or badge definitions using [shields.io’s JSON or endpoint integration](https://shields.io/endpoint).

---

## 🚀 Why does this exist?
- To keep metrics & badge information **decoupled** from the application code.
- To allow **centralized hosting** of metrics across multiple repositories.
- To ensure badges always reflect the **latest CI/CD pipeline results** (no extra commits to `main` needed).

---

## 🛠️ How it works
1. One [project](https://github.com/SebVay/Danger-Module-Report) merges to the `main` branch.
2. Bitrise runs the CI/CD pipeline for that project.
3. In the Pipeline, reports are generated and then committed here.
4. Repositories's README.md consume the generated files and badges here.
5. ???
6. Profits 💰

---

## 📂 Repository structure

- Each subfolder corresponds to a project.
- Each project has subfolder that corresponds to a module.
- Inside each of these folders, you’ll typically find:
  - **/index.html** → Reports overview
  - **/badges** → Project's Badges Metrics
  - **/module**
    - **/badges** → Module's Badges Metrics
    - **/jacoco** → Module's Jacoco HTML Report

---

## 📌 Notes

This repository is **automation-only**. Everything is overwritten by the next CI/CD run. 🧹

If you are visiting here, you are probably just curious. So, thank you ❤️  — the real work happens in the pipelines of my other projects using using [those scripts](https://github.com/SebVay/CI-CD-Badges/tree/main/ci). 
Feel free to drop me a line if you need assistance to reuse this repository.
