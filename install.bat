@echo off
powershell -Command "runas /user:immo-nrw\$($env:USERNAME -replace '^[^.]+' , 'admin') 'powershell -File \\fs1.immo-nrw.net\Trans$\#VERKNUEPFUNGEN\Rollen\ps1\check_windows_graph.ps1'"

pause