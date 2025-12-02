# Windows Persistence Lab (BO-BOBO VM)

This project is a hands-on lab I co-wrote for a university cybersecurity course.  
It walks through four different Windows persistence mechanisms using **only PowerShell** on a **BO-BOBO** virtual machine.

The goal of this lab is to help beginners understand how persistence works, how attackers might abuse it, and how defenders can detect and remove it.

---

## 🔍 Project Overview (for interviewers)

- **Role:** Co-author of the lab tutorial, script author, and tester
- **Focus:** Windows persistence techniques using PowerShell
- **Environment:** BO-BOBO Windows VM (no GUI), PowerShell-only
- **Skills Demonstrated:**
  - Windows internals: Registry, Startup folder, PowerShell profiles, WMI
  - Blue Team mindset: understanding persistence to better detect and remove it
  - PowerShell scripting and automation
  - Clear technical documentation for beginners

---

## 🧑‍🤝‍🧑 Collaboration & Academic Context

- This lab was created as part of a **university cybersecurity class**.
- I wrote this tutorial **together with a teammate**.
- I contributed to:
  - Designing the lab flow and explanations for beginners
  - Writing and testing the PowerShell commands
  - Creating the TestPersistence script and log-based verification steps
  - Writing cleanup steps to safely remove persistence

(If you’re an interviewer and want to know more about my specific contributions, I’m happy to walk through them.)

---

## 🧪 Lab Goal

All four persistence methods trigger **one harmless script** that logs the current date and time to a file:

- Script: `TestPersistence.ps1`
- Log file: `PersistenceLog.txt`

By checking the log file before and after each persistence method, we can confirm whether the persistence mechanism worked.

All commands are executed in **PowerShell**.

---

## ✅ Setup — Create the Test Script

First, log into your **BO-BOBO** virtual machine and open **PowerShell** (preferably as Administrator).

### Step 1 — Create the script

```powershell
"Add-Content `$env:USERPROFILE\Documents\PersistenceLog.txt `"[$(Get-Date)] Persistence ran.`"" |
Out-File "$env:USERPROFILE\Documents\TestPersistence.ps1"
