#!/bin/bash

REPO_DIR="winget-pkgs"
LETTER="$1"

# Function to test if a file is available
test_url() {
    local url=$1
    local response=$(curl -s -L --head -w "%{http_code}" "$url" -o /dev/null)
    if [ "$response" == "200" ]; then
        echo "File is available: $url"
    else
        echo -e "\e[31mFile is not available: $url\e[0m"
        echo "$PACKAGEIDENTIFIER,$PACKAGEVERSION,$url" >> fails.csv
    fi
}

# Check if the repository already exists
if [ -d "$REPO_DIR" ]; then
    # Repository exists, update it to the latest version
    cd "$REPO_DIR"
    git pull origin master
    cd ..
else
    # Repository doesn't exist, clone it
    git clone https://github.com/microsoft/winget-pkgs
fi

# Rest of your script...
find winget-pkgs/manifests/$LETTER/ -type f -name "*installer.yaml" | sort | while read -r file; do
    URLS=($(grep -E "InstallerUrl" "$file" | awk -F ': ' '{print $2}'))
    PACKAGEIDENTIFIER=$(grep -E "PackageIdentifier" "$file" | awk -F ': ' '{print $2}')
    PACKAGEVERSION=$(grep -E "PackageVersion" "$file" | awk -F ': ' '{print $2}')
    echo "File: $file"
    # echo "Package Identifier: $PACKAGEIDENTIFIER"
    # echo "Package Version: $PACKAGEVERSION"
    # echo "URLs: ${URLS[@]}"

        # Test each URL if it ends with .msi, .exe, or .zip
        for url in "${URLS[@]}"; do
            if [[ $url == *.msi || $url == *.exe || $url == *.zip ]]; then
                test_url "$url"
            fi
        done
    done

cat fails.csv | sort | uniq > fails_sorted.csv

