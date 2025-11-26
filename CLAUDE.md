# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This project unlocks complete Captain AI functionality in Chatwoot v4.8+, enabling all 7 menus instead of the default 3. It's an enhanced version of [CHypeTools/Dchat](https://github.com/CHypeTools/Dchat) specifically for Chatwoot v4.8 and newer versions.

## Key Differences from Original Dchat

The original Dchat (for v4.7 and earlier) only handles:
- PostgreSQL trigger creation
- Database configuration updates
- File patching for fallback values

This v4.8+ edition adds:
- **Automatic feature flag enablement** for `captain_integration` (V1)
- **Automatic feature flag enablement** for `captain_integration_v2` (V2)
- **Fixed JSON format** to avoid PostgreSQL type errors
- **Per-account verification** output

## Project Files

- **`unlock_captain_v4.8.rb`** - Main unlock script with feature flag enablement
- **`README.md`** - User-facing documentation
- **`TESTING.md`** - Complete testing guide with step-by-step instructions
- **`INSTALL.md`** - Detailed installation guide (if exists)
- **`CLAUDE.md`** - This file (developer documentation)

## Core Functionality

### 1. PostgreSQL Trigger (Permanent Protection)

Creates a BEFORE trigger that intercepts INSERT/UPDATE operations on `installation_configs` table:

```sql
CREATE TRIGGER trg_force_enterprise_configs
BEFORE INSERT OR UPDATE ON installation_configs
FOR EACH ROW
EXECUTE FUNCTION force_enterprise_installation_configs();
```

**Format Fix:**
- Rails expects YAML with `!ruby/hash:ActiveSupport::HashWithIndifferentAccess` when reading `InstallationConfig#value`.
- Store as JSONB string containing that YAML using `to_jsonb($$...yaml...$$::text)` to satisfy PostgreSQL `jsonb` while providing a Ruby `String` to the YAML coder.

### 2. Database Configurations

Sets three critical configs:
- `INSTALLATION_PRICING_PLAN` = `'enterprise'`
- `INSTALLATION_PRICING_PLAN_QUANTITY` = `9999999`
- `IS_ENTERPRISE` = `true`

All marked with `locked: true` to prevent UI modifications.

### 3. Feature Flag Enablement (NEW IN v4.8)

**This is the critical addition for v4.8+:**

```ruby
Account.find_each do |account|
  account.enable_features!('captain_integration', 'captain_integration_v2')
end
```

Without this step:
- Captain V1: Only 3 menus appear (FAQs, Documents, Playground)
- Captain V2: 4 additional menus don't appear (Scenarios, Tools, Guardrails, Guidelines)

With this step:
- **All 7 menus** appear and work without paywall

### 4. Redis Cache Clearing

Removes premium alert flags:
```ruby
Redis::Alfred.delete(Redis::Alfred::CHATWOOT_INSTALLATION_CONFIG_RESET_WARNING)
```

### 5. File Patching

Patches `/app/lib/chatwoot_hub.rb` to change hardcoded fallback values:
- Changes `|| 'community'` to `|| 'enterprise'`
- Changes `|| 0` to `|| 9999999`

Creates automatic timestamped backups before modifying.

## Captain V1 vs V2 Features

### Captain V1 (`captain_integration`)
Routes using `meta` (not `metaV2`):
- `captain_assistants_responses_index` - FAQs/Responses
- `captain_assistants_documents_index` - Documents
- `captain_assistants_playground_index` - Playground
- `captain_assistants_inboxes_index` - Inboxes
- `captain_assistants_settings_index` - Settings (basic)

### Captain V2 (`captain_integration_v2`)
Routes using `metaV2`:
- `captain_tools_index` - Custom Tools
- `captain_assistants_scenarios_index` - Scenarios
- `captain_assistants_guardrails_index` - Guardrails
- `captain_assistants_guidelines_index` - Response Guidelines

Found in: `app/javascript/dashboard/routes/dashboard/captain/captain.routes.js`

## Execution Methods

### Primary (wget from GitHub):
```bash
wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -
```

### Manual (file upload):
```bash
bundle exec rails runner /path/to/unlock_captain_v4.8.rb
```

### Docker exec wrapper:
```bash
docker exec -it <container> bash -c "wget -qO- URL | bundle exec rails runner -"
```

## Verification Output

The script outputs comprehensive verification:

```
🔍 Verification:
   • INSTALLATION_PRICING_PLAN: enterprise (locked: true)
   • INSTALLATION_PRICING_PLAN_QUANTITY: 9999999 (locked: true)
   • IS_ENTERPRISE: true (locked: true)
   • PostgreSQL Trigger: ✅ ACTIVE
   • Account #1 Captain V1: ✅ | V2: ✅
```

## Testing Requirements

Before releasing new versions, test must verify:

1. ✅ Fresh database (dropped and recreated)
2. ✅ Script executes without errors
3. ✅ Trigger is created successfully
4. ✅ All 3 configs are set correctly
5. ✅ Features are enabled for ALL accounts
6. ✅ Menu shows 7 submenus (not 3)
7. ✅ No paywall appears
8. ✅ Assistants can be created/edited
9. ✅ Persistence after container restart

See `TESTING.md` for complete test procedure.

## Common Issues & Solutions

### Issue: Only 3 menus appear
**Cause:** Feature flags weren't enabled (V2 missing)
**Solution:** Check feature enablement step in code

### Issue: Trigger creation fails with type error
**Cause:** Legacy/broken trigger in the database
**Solution:** Drop old trigger/function and re-run unlock script

### Issue: Menu doesn't appear after restart
**Cause:** Browser cache
**Solution:** Hard refresh or incognito mode

### Issue: Changes revert after update
**Cause:** Database was recreated
**Solution:** Re-run script (configs stored in DB)

## Important Code Patterns

### Feature Flag Check Pattern (Frontend)
```javascript
// In captain.routes.js
const meta = {
  permissions: ['administrator', 'agent'],
  featureFlag: FEATURE_FLAGS.CAPTAIN,  // V1
  installationTypes: [INSTALLATION_TYPES.CLOUD, INSTALLATION_TYPES.ENTERPRISE],
};

const metaV2 = {
  permissions: ['administrator', 'agent'],
  featureFlag: FEATURE_FLAGS.CAPTAIN_V2,  // V2
  installationTypes: [INSTALLATION_TYPES.CLOUD, INSTALLATION_TYPES.ENTERPRISE],
};
```

### Feature Flag Check Pattern (Backend)
```ruby
# In account.rb via Featurable concern
def feature_enabled?(name)
  send("feature_#{name}?")
end

# Usage:
account.feature_captain_integration?      # => true/false
account.feature_captain_integration_v2?   # => true/false
```

### Installation Type Check Pattern
Frontend needs:
```javascript
window.chatwootConfig = {
  isEnterprise: true,  // Must be boolean, not string!
  installationType: 'enterprise'  // Added in v4.8
}
```

## Dependencies

- **Rails**: InstallationConfig model
- **PostgreSQL**: Trigger support
- **Redis**: Optional (Redis::Alfred for cache clearing)
- **Chatwoot**: v4.8.0+ (feature_flags column in accounts table)

## File Paths Referenced

- `/app/lib/chatwoot_hub.rb` - Fallback values
- `/app/app/views/layouts/vueapp.html.erb` - Frontend config injection
- `/app/enterprise/app/controllers/enterprise/api/v1/accounts_controller.rb` - API controller
- `/app/app/javascript/dashboard/routes/dashboard/captain/captain.routes.js` - Routes

## Educational Use Only

This code is provided for educational purposes to understand:
- Chatwoot's enterprise feature system
- PostgreSQL trigger mechanisms
- Rails feature flag patterns
- Vue.js route protection patterns

Not intended for bypassing commercial licensing in production environments.

## Version History

### v4.8 Edition (2025-11-26)
- Added automatic V1 and V2 feature enablement
- Fixed JSON format for PostgreSQL compatibility
- Added per-account verification output
- Tested on Chatwoot v4.8.0

### Based on Original Dchat
- Trigger-based protection
- Database configuration updates
- File patching for fallbacks
