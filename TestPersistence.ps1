PERSISTENCE TUTORIAL 
A simple, easy-to-understand guide that you can follow on your BO-BOBO VM
Introduction 
In this tutorial, you will learn how a program can stay alive on a computer, even after restarting or logging off. This is called persistence.
Imagine putting a sticky note on your fridge that reminds you every morning. Persistence is like putting a sticky note on a computer, so it runs something every time it turns on.
You will learn four ways to create persistence on your BO-BOBO virtual machine:
1.	Using the Registry
2.	Using the Startup Folder
3.	Using the PowerShell Profile
4.	Using WMI (Windows Management Instrumentation)
All commands are done in PowerShell only.
We will use ONE harmless script that simply writes the date/time into a log file.
 Every persistence method will trigger this script.
Setup — Create the Test Script
Before we start, we need a tiny script that does something easy:
 add today’s date and time to a log file.
This helps us know when persistence works.
Log into your BO-BOBO Virtual machine and run PowerShell (might want to run as administrator)
Step 1: Create the script
Run this in PowerShell:
"Add-Content `$env:USERPROFILE\Documents\PersistenceLog.txt `"[$(Get-Date)] Persistence ran.`"" | Out-File "$env:USERPROFILE\Documents\TestPersistence.ps1"

Step 2: Test the script manually
Run:
& "$env:USERPROFILE\Documents\TestPersistence.ps1"
Then check the log:
Get-Content "$env:USERPROFILE\Documents\PersistenceLog.txt"
 You should see ONE line with a date/time. This means your script works.
PART 1 — Persistence Using the Registry
 Explanation:
The Windows Registry is like a giant notebook the computer reads from when it starts up.
 There's a special page where Windows looks for programs to run every time you log in.
Step 1: Add persistence
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v BoboboRegPersist /t REG_SZ /d "powershell.exe -ExecutionPolicy Bypass -File $env:USERPROFILE\Documents\TestPersistence.ps1" /f
Step 2: Restart and test
shutdown /r /t 0
After restart:
Get-Content "$env:USERPROFILE\Documents\PersistenceLog.txt"
You should see a new timestamp.
Step 3: Cleanup
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v BoboboRegPersist /f


PART 2 — Persistence Using the Startup Folder
Explanation:
Windows has a folder called Startup.
 Anything inside that folder runs every time the user logs in — just like putting a toy car on a racetrack that starts automatically when you press "go."
Since BO-BOBO has no GUI, we created a small .cmd file in the Startup folder.
Step 1: Create the startup launcher
"powershell.exe -ExecutionPolicy Bypass -File $env:USERPROFILE\Documents\TestPersistence.ps1" | Out-File "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\BoboboStart.cmd"
Step 2: Restart and test
shutdown /r /t 0
After restart:
Get-Content "$env:USERPROFILE\Documents\PersistenceLog.txt"

 You should see another new timestamp.
✔ Step 3: Cleanup
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\BoboboStart.cmd"
PART 3 — Persistence Using the PowerShell Profile
Explanation:
A PowerShell profile is like a “morning routine” for PowerShell.
 Every time PowerShell starts; it reads and runs the profile file.
If we put our test script in that file, PowerShell will run it every time it opens.
Step 1: Create the profile file (if missing)
New-Item -ItemType File -Path $profile -Force
Step 2: Add our persistence line
" & `"$env:USERPROFILE\Documents\TestPersistence.ps1`"" | Add-Content $profile
Step 3: Test
Close PowerShell, open it again, then run:
Get-Content "$env:USERPROFILE\Documents\PersistenceLog.txt"
You should see a new entry.
Step 4: Cleanup (remove the line)
(Get-Content $profile | Where-Object {$_ -notmatch "TestPersistence.ps1"}) | Set-Content $profile
PART 4 — Persistence Using WMI
 Explanation:
WMI is like a robot inside Windows that watches for events, like:
•	“Computer has been running for 20 seconds”
•	“a USB device was plugged in”
We will tell the robot:
“When the computer has been running for 20 seconds, run our script.”
This creates very sneaky persistence.
Step 1: Create WMI Filter
$filter = Set-WmiInstance -Class __EventFilter -Namespace root\subscription -Arguments @{
    Name = "BoboboFilter"
    EventNamespace = "root\cimv2"
    QueryLanguage = "WQL"
    Query = "SELECT * FROM Win32_PerfFormattedData_PerfOS_System WHERE SystemUpTime > 20"
}
Step 2: Create WMI Consumer
$consumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace root\subscription -Arguments @{
    Name = "BoboboConsumer"
    CommandLineTemplate = "powershell.exe -ExecutionPolicy Bypass -File $env:USERPROFILE\Documents\TestPersistence.ps1"
}
Step 3: Bind filter + consumer
Set-WmiInstance -Class __FilterToConsumerBinding -Namespace root\subscription -Arguments @{
    Filter = $filter
    Consumer = $consumer
}

Step 4: Restart and test
shutdown /r /t 0
After restart:
Get-Content "$env:USERPROFILE\Documents\PersistenceLog.txt"
 A new timestamp means WMI persistence worked!
Step 5: Cleanup WMI persistence
Get-WmiObject -Namespace root\subscription -Class __EventFilter | Where-Object Name -eq "BoboboFilter" | Remove-WmiObject
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer | Where-Object Name -eq "BoboboConsumer" | Remove-WmiObject
