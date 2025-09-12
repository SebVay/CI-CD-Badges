# CI-CD-Badges

📛 A CI/CD–maintained repository that stores and exposes project metrics (such as code coverage) in a way that can be consumed by other repositories to generate **live badges** via [shields.io](https://shields.io/) and other custom metrics.

---

## 📖 What is this?
This is not a repository meant for direct development.
Instead, it acts as a **data source** for metrics:
- Whenever a change is merged into the `main` branch of one of our projects, [Bitrise](https://www.bitrise.io/) workflows run.
- These workflows generate reports (e.g., code coverage, size metrics, etc.).
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
   
[![Jacoco](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FSebVay%2FCI-CD-Badges%2Frefs%2Fheads%2Fmain%2Fdanger-modules-report%2Fbadges%2Fcoverage.json)](https://sebvay.github.io/CI-CD-Badges/danger-modules-report/jacoco/test/html/index.html)

---

## 📂 Repository structure

- Each subfolder corresponds to a project.
- Inside each project folder, you’ll typically find:
 - **project/badges** → Badges Metrics
 - **project/jacoco** → Jacoco HTML Report

---

## 📌 Notes

This repository is **automation-only**. Everything is overwritten by the next CI/CD run. 🧹

If you are visiting here, you are probably just curious. So, thank you ❤️  — the real work happens in the pipelines of my other projects.
