#!/bin/bash

REPO_DIR="winget-pkgs"
LETTER="$1"

# Function to test if a file is available
test_url() {
    local url=$1
    local response=$(curl -s -L --head -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0" -w "%{http_code}" "$url" -o /dev/null)
    if [ "$response" == "200" ]; then
        # echo "File is available: $url"
        echo "$PACKAGEIDENTIFIER,$PACKAGEVERSION,$url,$response" >> tested_urls.csv
    elif [ "$response" == "404" ]; then
        echo -e "\e[31mFile may not be available: $url (HTTP response code: $response)\e[0m"
        echo "$PACKAGEIDENTIFIER,$PACKAGEVERSION,$url,$response" >> tested_urls.csv
    fi
    else
        echo -e "\e[31mFile may not be available: $url (HTTP response code: $response)\e[0m"
        echo "$PACKAGEIDENTIFIER,$PACKAGEVERSION,$url,$response" >> tested_urls.csv
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
file_count=$(find winget-pkgs/manifests/$LETTER/ -type f -name "*installer.yaml" | wc -l)
url_count=$(find winget-pkgs/manifests/$LETTER/ -type f -name "*installer.yaml" | xargs grep -E "InstallerUrl" | wc -l)
echo "Number of installer files to check: $file_count"
echo "Number of URLs to check: $url_count"

find winget-pkgs/manifests/$LETTER/ -type f -name "*installer.yaml" | sort | while read -r file; do
    URLS=($(grep -E "InstallerUrl" "$file" | awk -F ': ' '{print $2}'))
    PACKAGEIDENTIFIER=$(grep -E "PackageIdentifier" "$file" | awk -F ': ' '{print $2}')
    PACKAGEVERSION=$(grep -E "PackageVersion" "$file" | awk -F ': ' '{print $2}')
    # echo "File: $file"
    # echo "Package Identifier: $PACKAGEIDENTIFIER"
    # echo "Package Version: $PACKAGEVERSION"
    # echo "URLs: ${URLS[@]}"

    # Test each URL
    for url in "${URLS[@]}"; do
        # sleep $((RANDOM % 3 + 1)) # Add random wait between 1 to 3 seconds
        sleep 0.2
        test_url "$url"
    done
done