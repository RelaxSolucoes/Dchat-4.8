# Installation Guide - Dchat Captain v4.8+

Complete installation guide with multiple methods for different environments.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Method 1: Docker Auto-Detect (Easiest)](#method-1-docker-auto-detect-easiest)
- [Method 2: Portainer Web UI](#method-2-portainer-web-ui)
- [Method 3: Direct Download](#method-3-direct-download)
- [Method 4: Manual Container Access](#method-4-manual-container-access)
- [Verification](#verification)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- ✅ Chatwoot v4.8.0 or higher installed
- ✅ Docker or Portainer access
- ✅ Terminal/SSH access to your server (for most methods)
- ✅ Administrator permissions
- ✅ **Recommended**: Database backup

---

## Method 1: Docker Auto-Detect (Easiest)

**Best for:** Users with terminal/SSH access who want the simplest solution.

### Steps:

1. **Connect to your server** via SSH

2. **Run the auto-detect script:**
   ```bash
   curl -sL https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/docker-unlock.sh | bash
   ```

3. **Wait for completion** - You'll see:
   ```
   🚀 Dchat Captain v4.8+ - Docker Auto-Unlock

   🔍 Searching for Chatwoot container...
   ✅ Found container: chatwoot_chatwoot_app.1.xxxxx

   📦 Container: chatwoot_chatwoot_app.1.xxxxx
   🌐 Downloading unlock script from GitHub...
   ```

4. **Follow the on-screen instructions** to restart the container

### What it does automatically:

- ✅ Finds your Chatwoot container (no need to know the name)
- ✅ Downloads the unlock script
- ✅ Executes the script
- ✅ Shows next steps

---

## Method 2: Portainer Web UI

**Best for:** Users who manage Docker via Portainer and prefer GUI over terminal.

### Steps:

1. **Access Portainer** Web UI

2. **Go to Containers**

3. **Find your Chatwoot container** (usually named like `chatwoot_app` or `chatwoot_chatwoot_app`)

4. **Click on the container** name

5. **Click "Console"** tab

6. **Click "Connect"** and select `/bin/bash`

7. **In the console, paste and execute:**
   ```bash
   wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -
   ```

8. **Wait for completion** - You'll see the verification output

9. **Go back to Containers** list

10. **Click the restart icon** ↻ next to your Chatwoot container

11. **Wait 1-2 minutes** for container to restart

12. **Access Chatwoot** and check the Captain menu

---

## Method 3: Direct Download

**Best for:** Users who know their container name and have terminal access.

### Steps:

1. **Find your container name:**
   ```bash
   docker ps | grep chatwoot
   ```

   Look for something like: `chatwoot_chatwoot_app.1.xxxxx` or `chatwoot-app`

2. **Execute the unlock script:**
   ```bash
   docker exec -it <container_name> bash -c \
     "wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -"
   ```

   Replace `<container_name>` with your actual container name.

3. **Restart the container:**
   ```bash
   docker restart <container_name>
   ```

4. **Access Chatwoot** after 1-2 minutes

---

## Method 4: Manual Container Access

**Best for:** Advanced users or when other methods fail.

### Steps:

1. **Enter the container:**
   ```bash
   docker exec -it <container_name> bash
   ```

2. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb -O /tmp/unlock.rb
   ```

3. **Execute the script:**
   ```bash
   bundle exec rails runner /tmp/unlock.rb
   ```

4. **Exit the container:**
   ```bash
   exit
   ```

5. **Restart the container:**
   ```bash
   docker restart <container_name>
   ```

---

## Verification

### Expected Output

After running the script, you should see:

```
🚀 === Dchat Captain - Complete Unlock for v4.8+ ===

📊 Creating permanent PostgreSQL trigger...
✅ Trigger created successfully!

💾 Updating installation configurations...
✅ INSTALLATION_PRICING_PLAN: enterprise
✅ INSTALLATION_PRICING_PLAN_QUANTITY: 9999999
✅ IS_ENTERPRISE: true

🔓 Enabling Captain V1 and V2 features...
  ✅ Account #1: [Your Account Name]
✅ Captain enabled for 1 account(s)

✅ Redis cache cleared

📁 Patching fallback values in /app/lib/chatwoot_hub.rb...
💾 Backup: /app/lib/chatwoot_hub.rb.backup.20251126_123456
✅ Fallback values updated

🔍 Verification:
   • INSTALLATION_PRICING_PLAN: enterprise (locked: true)
   • INSTALLATION_PRICING_PLAN_QUANTITY: 9999999 (locked: true)
   • IS_ENTERPRISE: true (locked: true)
   • PostgreSQL Trigger: ✅ ACTIVE
   • Account #1 Captain V1: ✅ | V2: ✅

🎉 === Unlock Complete ===
```

### Check in Browser

1. Access your Chatwoot instance
2. Login with your account
3. Look for **Captain** menu in the sidebar
4. Click to expand - should show **7 submenus**:
   - FAQs
   - Documentos
   - Cenários
   - Playground
   - Caixas de Entrada
   - Ferramentas
   - Configurações

5. Click any submenu - **NO paywall** should appear
6. Try creating an assistant - should work without restrictions

---

## Post-Installation

### Restart Container (Required)

**Via Docker CLI:**
```bash
docker restart <container_name>
```

**Via Portainer:**
1. Go to Containers
2. Find your Chatwoot container
3. Click the restart icon ↻
4. Wait 1-2 minutes

### Clear Browser Cache (Recommended)

1. Press `Ctrl + Shift + Delete` (or `Cmd + Shift + Delete` on Mac)
2. Select "Cached images and files"
3. Click "Clear data"
4. Or use Incognito/Private mode

### Verify Persistence

To ensure it's truly permanent:

1. Restart the container again
2. Check if Captain menu still appears with all 7 menus
3. Try to disable via Super Admin (it should remain enabled due to trigger protection)

---

## Troubleshooting

### Container Not Found

**Error:** `Could not find Chatwoot container`

**Solution:** Find your container manually:
```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

Look for containers with `chatwoot` in the name or image.

### wget: command not found

**Error:** `bash: wget: command not found`

**Solution:** Use `curl` instead:
```bash
curl -sL https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -
```

### Permission Denied

**Error:** `Permission denied`

**Solution:** Ensure you have Docker permissions:
```bash
sudo usermod -aG docker $USER
```

Then logout and login again, or use `sudo`:
```bash
sudo docker exec -it <container> bash
```

### Trigger Creation Failed

**Error:** `Trigger creation failed: ERROR: could not determine polymorphic type`

**Solution:** Old buggy trigger exists. Remove it first:
```bash
docker exec -it <postgres_container> psql -U postgres -d chatwoot -c \
  "DROP TRIGGER IF EXISTS trg_force_enterprise_configs ON installation_configs; \
   DROP FUNCTION IF EXISTS force_enterprise_installation_configs();"
```

Then run the unlock script again.

### Only 3 Menus Appear (Even After Successful Unlock)

**Cause 1:** Captain V2 wasn't enabled

**Solution:** Run manually:
```bash
docker exec -it <chatwoot_container> bundle exec rails runner \
  "Account.find_each { |a| a.enable_features!('captain_integration_v2') }; puts 'V2 enabled'"
```

Reload the page.

---

**Cause 2:** ⚠️ **CRITICAL - Old Assets Volume** (Most Common)

If you upgraded from an older Chatwoot version but kept the `chatwoot_public` volume, it contains **outdated frontend assets** from before v4.8. Even though the unlock works perfectly in the backend, the old JavaScript files don't support Captain V2!

**Symptoms:**
- Backend shows: `Captain V1: ✅ | V2: ✅` (correct)
- Frontend only shows 3 menus (old assets)
- No error 404 for `/limits` in browser console

**Check if this is your issue:**
```bash
# Check asset dates inside container
docker exec -it <chatwoot_container> ls -lh /app/public/vite/assets/ | head -5

# If dates are older than November 2024, your volume has old assets!
```

**Solution - Delete Old Assets Volume:**

⚠️ **Important:** This is safe! The `chatwoot_public` volume only contains static assets (JavaScript, CSS, icons). NO user data, messages, or uploads are stored here!

**Via Portainer (Recommended):**
1. Go to **Stacks** → Stop your Chatwoot stack
2. Go to **Volumes** → Find `chatwoot_public`
3. Click **Remove** (it will be recreated with new assets)
4. Go back to **Stacks** → Start your stack
5. Wait 2-3 minutes for container to fully start
6. Access Chatwoot → Logout/Login → Check for 7 menus! 🎉

**Via Command Line:**
```bash
# Stop stack first
docker stack rm chatwoot  # or: docker-compose down

# Remove old volume
docker volume rm chatwoot_chatwoot_public

# Start stack again - volume will be recreated with new assets
docker stack deploy -c docker-compose.yml chatwoot
```

**Why this happens:**
Docker preserves volume contents when you update images. If you upgraded from Chatwoot v4.7 or earlier to v4.8+, the old JavaScript files remain in the volume and override the new ones from the image.

### Menu Doesn't Appear After Restart

**Cause:** Browser cache

**Solution:**
1. Hard refresh: `Ctrl + F5` (or `Cmd + Shift + R` on Mac)
2. Clear browser cache
3. Try incognito/private mode
4. Try different browser

---

## Alternative Installation Methods

### From File Upload

If you can't access the internet from the server:

1. Download `unlock_captain_v4.8.rb` to your computer
2. Upload to server using SCP:
   ```bash
   scp unlock_captain_v4.8.rb user@server:/tmp/
   ```
3. Execute on server:
   ```bash
   docker cp /tmp/unlock_captain_v4.8.rb <container>:/tmp/
   docker exec -it <container> bundle exec rails runner /tmp/unlock_captain_v4.8.rb
   ```

### Using docker-compose

If using docker-compose instead of Docker Swarm:

```bash
# Find service name
docker-compose ps

# Execute unlock
docker-compose exec chatwoot_app bash -c \
  "wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -"

# Restart
docker-compose restart chatwoot_app
```

---

## Need Help?

- 📖 [Testing Guide](TESTING.md) - Complete testing procedure
- 🐛 [GitHub Issues](https://github.com/RelaxSolucoes/Dchat-4.8/issues) - Report problems
- 📚 [Original Dchat](https://github.com/CHypeTools/Dchat) - Based on this project

---

## Security Note

⚠️ This unlock modifies enterprise licensing restrictions. Use only for:
- Educational purposes
- Testing environments
- Environments where you have proper licensing

Always ensure compliance with Chatwoot's license terms.
