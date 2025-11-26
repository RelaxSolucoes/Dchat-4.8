#!/bin/bash
# Dchat Captain v4.8+ - Docker Auto-Unlock Script
# Auto-detects Chatwoot container and runs the unlock script

set -e

echo "🚀 Dchat Captain v4.8+ - Docker Auto-Unlock"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to find Chatwoot container
find_chatwoot_container() {
    echo "🔍 Searching for Chatwoot container..."

    # Try common container name patterns
    local patterns=(
        "chatwoot_app"
        "chatwoot-app"
        "chatwoot_web"
        "chatwoot-web"
        "chatwoot"
    )

    for pattern in "${patterns[@]}"; do
        local container=$(docker ps --filter "name=$pattern" --format "{{.Names}}" | head -n 1)
        if [ ! -z "$container" ]; then
            echo -e "${GREEN}✅ Found container: $container${NC}"
            echo "$container"
            return 0
        fi
    done

    # Try by image name
    local container=$(docker ps --filter "ancestor=chatwoot/chatwoot" --format "{{.Names}}" | head -n 1)
    if [ ! -z "$container" ]; then
        echo -e "${GREEN}✅ Found container by image: $container${NC}"
        echo "$container"
        return 0
    fi

    return 1
}

# Find container
CONTAINER=$(find_chatwoot_container)

if [ -z "$CONTAINER" ]; then
    echo -e "${RED}❌ Error: Could not find Chatwoot container${NC}"
    echo ""
    echo "Please specify the container name manually:"
    echo "  docker exec -it <container_name> bash -c \"wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -\""
    echo ""
    echo "Available containers:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    exit 1
fi

echo ""
echo "📦 Container: $CONTAINER"
echo "🌐 Downloading unlock script from GitHub..."
echo ""

# Execute the unlock script
docker exec -it "$CONTAINER" bash -c "wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}🎉 Unlock completed successfully!${NC}"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Restart the Chatwoot container:"
    echo "     docker restart $CONTAINER"
    echo ""
    echo "  2. Wait 1-2 minutes for the container to fully restart"
    echo ""
    echo "  3. Access Chatwoot and check the Captain menu"
    echo "     You should see all 7 submenus without paywall"
    echo ""
else
    echo -e "${RED}❌ Unlock failed with exit code: $EXIT_CODE${NC}"
    echo ""
    echo "Please check the error messages above and try again."
    echo "If the problem persists, see: https://github.com/RelaxSolucoes/Dchat-4.8/blob/main/TESTING.md"
fi

exit $EXIT_CODE
