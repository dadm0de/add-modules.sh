#!/bin/bash
set -e

# ========================
#       ASCII Banner
# ========================
cat << "EOF"
Add
 /$$      /$$  /$$$$$$  /$$$$$$$  /$$   /$$ /$$       /$$$$$$$$  /$$$$$$ 
| $$$    /$$$ /$$__  $$| $$__  $$| $$  | $$| $$      | $$_____/ /$$__  $$
| $$$$  /$$$$| $$  \ $$| $$  | $$| $$  | $$| $$      | $$      | $$  \__/
| $$ $$/$$ $$| $$  | $$| $$  | $$| $$  | $$| $$      | $$$$$   |  $$$$$$ 
| $$  $$$| $$| $$  | $$| $$  | $$| $$  | $$| $$      | $$__/    \____  $$
| $$\  $ | $$| $$  | $$| $$  | $$| $$  | $$| $$      | $$       /$$  \ $$
| $$ \/  | $$|  $$$$$$/| $$$$$$$/|  $$$$$$/| $$$$$$$$| $$$$$$$$|  $$$$$$/
|__/     |__/ \______/ |_______/  \______/ |________/|________/ \______/ 
                                                                   Script
                   For AzerothCore Playerbots Branch
EOF

# Description
echo ""
echo "This script allows you to add AzerothCore modules via Git links,"
echo "compiles them incrementally, and copies their .conf.dist files"
echo "to the proper environment folder if compilation succeeds."
echo "If a module fails to compile, it is removed automatically."
echo "At the end, the script will list all successful and failed modules."
echo ""

# ========================
#       Configuration
# ========================
MODDIR="$HOME/azerothcore-wotlk/modules"
BUILDDIR="$HOME/azerothcore-wotlk/var/build/obj"
CONFDIR="$HOME/azerothcore-wotlk/env/dist/etc/modules"
SRCDIR="$HOME/azerothcore-wotlk"

# ========================
#       Prompt for Git links
# ========================
echo "Enter Git links for modules, one per line. Press Enter on an empty line when done:"
mods=()
while true; do
    read -r link
    [[ -z "$link" ]] && break
    mods+=("$link")
done

if [ ${#mods[@]} -eq 0 ]; then
    echo "No modules provided. Exiting."
    exit 1
fi

cd "$MODDIR"

good=()
bad=()

# ========================
#       Process each module
# ========================
for repo in "${mods[@]}"; do
    name=$(basename "$repo" .git)
    echo ""
    echo "=== Adding $name ==="

    # Remove old copy if exists
    rm -rf "$MODDIR/$name"

    # Clone directly into the modules folder
    git clone "$repo" "$MODDIR/$name"

    echo "=== Incremental build for $name ==="

    # Go to build folder
    cd "$BUILDDIR"

    # Run CMake incrementally
    cmake "$SRCDIR" > /dev/null

    # Compile the core incrementally
    if make -j"$(nproc)"; then
        echo "✅ $name compiled successfully"
        good+=("$name")

        # Copy all .conf.dist files
        conf_files=$(find "$MODDIR/$name/conf" -name "*.conf.dist" 2>/dev/null)
        for conf_file in $conf_files; do
            conf_name=$(basename "$conf_file" .dist)
            cp "$conf_file" "$CONFDIR/$conf_name"
            echo "📂 Copied config to $CONFDIR/$conf_name"
        done
    else
        echo "❌ $name FAILED to compile."
        echo "   The module folder will be removed to avoid partial or broken installs."
        bad+=("$name")
        rm -rf "$MODDIR/$name"
    fi
done

# ========================
#       Summary
# ========================
echo ""
echo "===== MODULE COMPILE SUMMARY ====="

# Always list successful modules (or empty)
echo "✅ Successful modules: ${good[*]:-None}"

# Always list failed modules (or empty)
echo "❌ Failed modules: ${bad[*]:-None}"
