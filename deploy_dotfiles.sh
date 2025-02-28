
#!/bin/bash
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# Function to create a symlink
symlinkFile() {
    local filename="$SCRIPT_DIR/$1"
    local dest_dir="$HOME/$2"
    local dest_file="$dest_dir/$(basename "$1")"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Check if destination is already a symlink
    if [ -L "$dest_file" ]; then
        echo "[WARNING] $dest_file already symlinked"
        return
    fi
    
    # Check if destination exists but is not a symlink
    if [ -e "$dest_file" ]; then
        echo "[ERROR] $dest_file exists but it's not a symlink. Please fix that manually"
        exit 1
    fi
    
    # Create the symlink
    ln -s "$filename" "$dest_file"
    echo "[OK] $filename -> $dest_file"
}

# Function to parse TOML and deploy files
deployTOMLManifest() {
    local manifest="$SCRIPT_DIR/$1"
    
    if [ ! -f "$manifest" ]; then
        echo "[ERROR] Manifest file not found: $manifest"
        exit 1
    fi
    
    echo "Deploying from manifest: $manifest"
    
    # Use awk to parse the TOML file
    # This is a simplified parser and may not handle all TOML features
    awk '
    BEGIN { current_file = ""; }
    
    # Match section headers like [".vimrc"]
    /^\[.*\]/ {
        gsub(/^\[|\]$/, "", $0);  # Remove the brackets
        gsub(/^"|"$/, "", $0);    # Remove quotes if present
        current_file = $0;
        operation = "";
        destination = "";
    }
    
    # Match key-value pairs
    /^[a-zA-Z]/ {
        if (current_file != "") {
            split($0, parts, "=");
            key = parts[1];
            value = parts[2];
            
            # Trim whitespace
            gsub(/^[ \t]+|[ \t]+$/, "", key);
            gsub(/^[ \t]+|[ \t]+$/, "", value);
            
            # Remove quotes from value
            gsub(/^"|"$/, "", value);
            gsub(/^'"'"'|'"'"'$/, "", value);
            
            if (key == "operation") {
                operation = value;
            } else if (key == "destination") {
                destination = value;
            }
            
            # If we have both operation and destination, process the file
            if (operation != "" && current_file != "") {
                printf("%s|%s|%s\n", current_file, operation, destination);
                operation = "";
                destination = "";
            }
        }
    }
    ' "$manifest" | while IFS="|" read -r filename operation dest; do
        case $operation in
            "symlink")
                symlinkFile "$filename" "$dest"
                ;;
            *)
                echo "[WARNING] Unknown operation: $operation for file: $filename. Skipping..."
                ;;
        esac
    done
}

# Check if a manifest file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <MANIFEST_FILE.toml>"
    echo "ERROR: No manifest file provided"
    exit 1
fi

# Deploy the manifest
deployTOMLManifest "$1"

echo "Deployment complete!"
