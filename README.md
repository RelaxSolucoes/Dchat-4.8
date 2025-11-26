# Chatwoot Captain Complete Unlock - v4.8+

![Chatwoot Version](https://img.shields.io/badge/Chatwoot-v4.8.0+-blue)
![License](https://img.shields.io/badge/License-Educational-yellow)
![Status](https://img.shields.io/badge/Status-Tested-green)

Unlock **all 7 Captain AI menus** in Chatwoot v4.8+ for educational purposes.

## 🎯 What This Does

Unlocks complete Captain AI functionality with **all 7 menus** instead of just 3:

### ✅ Captain V1 Features (3 menus)
- 📝 FAQs / Responses
- 📚 Documents
- 🎮 Playground
- 📧 Inboxes
- ⚙️ Settings (basic)

### ✨ Captain V2 Features (4 additional menus)
- 🎭 Scenarios
- 🔧 Tools (Custom Tools)
- 🛡️ Guardrails
- 📖 Guidelines

**Result: Complete 7-menu Captain interface without paywall**

## ⚠️ IMPORTANT: Captain V2 Compatibility Issue

**Known Issue with Captain V2 and Custom Endpoints:**

Captain V2 (which provides the additional 4 menus: Scenarios, Tools, Guardrails, Guidelines) has a configuration compatibility issue when using **custom API endpoints** like OpenRouter or even standard OpenAI endpoints in some cases.

**The Problem:**
- Captain V2 uses the `ai-agents` gem which expects `RubyLLM.configure` setup
- The unlock script sets configurations via `InstallationConfig` table
- These configurations are not properly loaded by the `ai-agents` gem
- Result: `RubyLLM::ConfigurationError: "openai provider is not configured..."`

**Recommended Approaches:**

1. **V1 Only (Stable - Recommended for most users):**
   - Enables 3 core Captain menus that work reliably with any endpoint
   - Modify the script to only enable `captain_integration` (V1)
   - Works perfectly with OpenRouter, OpenAI, and other custom endpoints

2. **V1 + V2 (Experimental - May require manual configuration):**
   - Enables all 7 menus but V2 features may not work with custom endpoints
   - Requires proper RubyLLM configuration in `/config/initializers/ai_agents.rb`
   - Best for users who plan to use only OpenAI's official endpoint

**Quick Fix if V2 Causes Issues:**
```bash
docker exec -it <chatwoot_container> bundle exec rails runner "
  Account.find_each { |a| a.disable_features('captain_integration_v2') }
  puts 'V2 disabled - V1 still active'
"
```

## 🆚 Difference from Original Dchat

[CHypeTools/Dchat](https://github.com/CHypeTools/Dchat) works great for Chatwoot v4.7, but in **v4.8+** the Captain menu doesn't show completely because feature flags are missing.

This enhanced version adds:
- ✅ Automatic `captain_integration` (V1) enablement
- ✅ Automatic `captain_integration_v2` (V2) enablement
- ✅ Fixed JSON format to prevent PostgreSQL type errors
- ✅ Per-account verification output

## 📋 Prerequisites

- Chatwoot v4.8.0 or higher
- Docker/Portainer or container access
- PostgreSQL with trigger support
- Administrator permissions

## ⚙️ Configuration

Before running the unlock, decide which version to enable by editing line 17 in `unlock_captain_v4.8.rb`:

```ruby
ENABLE_V2 = false  # Recommended: V1 only (stable with custom endpoints)
# OR
ENABLE_V2 = true   # V1 + V2 (experimental, may have issues)
```

**Recommendation**: Keep `ENABLE_V2 = false` for compatibility with OpenRouter, OpenAI, and other custom endpoints.

## 🚀 Quick Start

### Method 1: Docker Auto-Detect (Easiest)

```bash
curl -sL https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/docker-unlock.sh | bash
```

This script automatically:
- ✅ Finds your Chatwoot container
- ✅ Downloads and executes the unlock script
- ✅ Shows next steps

### Method 2: Direct Download

If you know your container name:

```bash
docker exec -it <chatwoot_container> bash -c \
  "wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -"
```

### Method 3: Traditional Installation

Execute directly in the Chatwoot container:

```bash
wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -
```

## ✅ Verification

After execution, you should see:

```
🎉 === Unlock Complete ===

📋 Applied:
  • Enterprise configurations with permanent trigger protection
  • Captain V1 (FAQs, Documents, Playground, Inboxes, Settings)
  • Captain V2 (Scenarios, Tools, Guardrails, Guidelines)

🔍 Verification:
   • INSTALLATION_PRICING_PLAN: enterprise (locked: true)
   • INSTALLATION_PRICING_PLAN_QUANTITY: 9999999 (locked: true)
   • IS_ENTERPRISE: true (locked: true)
   • PostgreSQL Trigger: ✅ ACTIVE
   • Account #1 Captain V1: ✅ | V2: ✅
```

## 🔄 Post-Installation

1. **Restart** the Chatwoot container:
   ```bash
   docker restart <chatwoot_container>
   ```

2. **Login** to Chatwoot

3. **Check** the Captain menu - should show all 7 submenus

4. **Test** creating an assistant - no paywall should appear

---

## ⚠️ IMPORTANT: Upgrading from v4.7 or Earlier?

If you upgraded from Chatwoot v4.7 (or earlier) to v4.8+ and only see **3 menus** instead of 7 after the unlock:

**Problem:** Your `chatwoot_public` Docker volume contains **old frontend assets** that don't support Captain V2.

**Solution:** Delete the `chatwoot_public` volume (safe - only contains static files, NO user data):

**Via Portainer:**
1. Stop stack → Volumes → Remove `chatwoot_public` → Start stack

**Via Command Line:**
```bash
docker stack rm chatwoot
docker volume rm chatwoot_chatwoot_public
docker stack deploy -c docker-compose.yml chatwoot
```

After recreating, you'll see all 7 menus! See [INSTALL.md](INSTALL.md#only-3-menus-appear-even-after-successful-unlock) for details.

## 🧪 Tested On

- ✅ Chatwoot v4.8.0
- ✅ Docker Swarm + Portainer
- ✅ PostgreSQL 14+
- ✅ Redis

## 🔧 Troubleshooting

### Captain menu doesn't appear

Check if features were enabled:

```bash
docker exec -it <container> bundle exec rails runner "
  account = Account.first
  puts 'Captain V1: ' + account.feature_captain_integration?.to_s
  puts 'Captain V2: ' + account.feature_captain_integration_v2?.to_s
"
```

Both should show `true`.

### Only 3 menus appear (instead of 7)

Captain V2 wasn't enabled. Run manually:

```bash
docker exec -it <container> bundle exec rails runner "
  Account.find_each { |a| a.enable_features!('captain_integration_v2') }
  puts 'V2 enabled'
"
```

### Error 500 when accessing

Pode ser problema de formato nas configurações. Verifique via API do modelo:

```bash
docker exec -it <container> bundle exec rails runner "
  c = InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')
  puts c.value.inspect
"
```

Deve mostrar: `"enterprise"`

### RubyLLM::ConfigurationError - openai provider is not configured

**Error in Sidekiq logs:**
```
error=#<RubyLLM::ConfigurationError: "openai provider is not configured...">
```

**Cause:** Captain V2 is enabled but the `ai-agents` gem cannot load the InstallationConfig values.

**Solution 1 - Disable V2 (Recommended):**
```bash
docker exec -it <container> bundle exec rails runner "
  Account.find_each { |a| a.disable_features('captain_integration_v2') }
  puts 'Captain V2 disabled - V1 will continue working'
"
docker restart <container>
```

**Solution 2 - Use V1-only unlock script:**
Modify the unlock script to only enable V1 (see script modifications section).

## 🔒 Persistence

Configurations are **permanent** because:

1. ✅ PostgreSQL trigger intercepts any modification attempts
2. ✅ Configs marked as `locked = true`
3. ✅ Captain features saved in database
4. ✅ Automatic backup of chatwoot_hub.rb

Persists through:
- Container restarts
- Chatwoot updates (unless database is recreated)
- New deployments

## 🗑️ Removal

To revert the unlock:

```bash
# 1. Remove trigger
docker exec -it <postgres_container> psql -U postgres -d chatwoot -c \
  "DROP TRIGGER IF EXISTS trg_force_enterprise_configs ON installation_configs; \
   DROP FUNCTION IF EXISTS force_enterprise_installation_configs();"

# 2. Disable Captain
docker exec -it <chatwoot_container> bundle exec rails runner "
  Account.find_each { |a| a.disable_features!('captain_integration', 'captain_integration_v2') }
"

# 3. Restore configs
docker exec -it <chatwoot_container> bundle exec rails runner "
  InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')&.update(value: 'community', locked: false)
  InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')&.update(value: 0, locked: false)
"
```

## ⚠️ Important Notices

- **Educational Use**: This script is for educational and testing purposes only
- **Backup**: Always backup your database before executing
- **Testing**: Test in development environment first
- **License**: Check Chatwoot's license terms before using in production

## 📚 Documentation

- [Installation Guide](INSTALL.md) - Detailed setup instructions
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions

## 🙏 Credits

- Based on: [CHypeTools/Dchat](https://github.com/CHypeTools/Dchat)
- Enhanced for v4.8+ with automatic Captain V1/V2 feature enablement
- Educational Project

## 📝 Changelog

### v4.8.1 Edition (2025-11-26)
- 🔧 **BREAKING**: Changed default to V1 only (`ENABLE_V2 = false`)
- ⚠️ Added configurable Captain version selection (V1 only vs V1+V2)
- 📚 Documented Captain V2 compatibility issues with custom endpoints
- 🐛 Added troubleshooting for `RubyLLM::ConfigurationError`
- 💡 Added configuration guide for choosing between V1 and V2
- ✅ Improved verification output to show selected version

### v4.8 Edition (2025-11-26)
- ✨ Added automatic Captain V1 and V2 feature enablement
- 🐛 Fixed JSON format for PostgreSQL trigger
- ✅ Verified on Chatwoot v4.8.0
- 📝 Added comprehensive verification output
- 🔍 Added per-account feature status check

## 📄 License

Educational purposes only. Use at your own risk.

---

Made with ❤️ for the Chatwoot community
