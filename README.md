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

May be JSON format issue in configurations. Check:

```bash
docker exec -it <container> bundle exec rails runner "
  puts InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN').serialized_value.inspect
"
```

Should show: `{"value"=>"enterprise"}`

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
