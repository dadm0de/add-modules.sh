This script allows you to add AzerothCore modules via Git links, compiles them incrementally, and copies their .conf.dist files to the proper environment folder if compilation succeeds. If a module fails to compile, it is removed automatically. At the end, the script will list all successful and failed modules.
Usage: Two Options
1. You can download this script
Fix permissions:
`chmod +x add-modules.sh`

Then run with
`./add-modules.sh`
   
2. Copy and Paste the script code:
`nano add-modules.sh`

copy code, save & exit
Fix permissions:
 `chmod +x add-modules.sh`

Run with:
`/.add-modules.sh`
