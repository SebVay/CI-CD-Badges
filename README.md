# CI-CD-Badges

📛 A CI/CD–maintained repository that stores and exposes project metrics (such as code coverage) in a way that can be consumed by other repositories to generate (for now) **live badges** via [shields.io](https://shields.io/).

---

## 📖 What is this?
This repository is not meant for direct development.  
Instead, it acts as a **data source**:  
- Whenever a change is merged into the `main` branch of one of our projects, [Bitrise](https://www.bitrise.io/) workflows run.  
- These workflows generate reports (e.g., code coverage, size metrics, etc.).  
- The results are pushed here, in a consistent format.  
- Other repositories can then point their badge definitions to these files using [shields.io’s JSON or endpoint integration](https://shields.io/endpoint).  

---

## 🚀 Why does this exist?
- To keep badge information **decoupled** from the application code.  
- To allow **centralized hosting** of metrics across multiple repositories.  
- To ensure badges always reflect the **latest CI/CD pipeline results** (no extra commits to `main` needed).  

---

## 🛠️ How it works
1. A [project](https://github.com/SebVay/Danger-Module-Report) merges to its `main` branch.  
2. Bitrise runs the CI/CD pipeline for that project.  
3. Reports are generated and committed here (in **JSON** & **html**).  
4. Badges in other repositories read directly from these files via shields.io.

## 📂 Repository structure

- Each subfolder corresponds to a project.
- Inside each project folder, you’ll typically find:
 - **jacoco/test/coverage.json** → Coverage metrics
 - **jacoco/test/html** → Html report

## 📌 Notes

This repository is **automation-only**. Everything is overwritten by the next CI/CD run. 🧹

If you are visiting here, you are probably just curious. So, thank you ❤️  — the real work happens in the pipelines of my other projects.
