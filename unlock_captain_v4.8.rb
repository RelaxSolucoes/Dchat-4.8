#!/usr/bin/env ruby
# Dchat Captain Unlock - Complete Edition for Chatwoot v4.8+
# Based on https://github.com/CHypeTools/Dchat with Captain feature flags
# Educational purposes only

require 'fileutils'
require 'yaml'
require 'active_support/hash_with_indifferent_access'

puts "🚀 === Dchat Captain - Complete Unlock for v4.8+ ==="
puts ""

# 1. Create PostgreSQL trigger (permanent protection)
sql_trigger = <<-SQL
CREATE OR REPLACE FUNCTION force_enterprise_installation_configs()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.name = 'INSTALLATION_PRICING_PLAN' THEN
        NEW.serialized_value = '---\nvalue: enterprise\n';
        NEW.locked = true;
    END IF;

    IF NEW.name = 'INSTALLATION_PRICING_PLAN_QUANTITY' THEN
        NEW.serialized_value = '---\nvalue: 9999999\n';
        NEW.locked = true;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_force_enterprise_configs ON installation_configs;

CREATE TRIGGER trg_force_enterprise_configs
BEFORE INSERT OR UPDATE ON installation_configs
FOR EACH ROW
EXECUTE FUNCTION force_enterprise_installation_configs();
SQL

begin
  puts "📊 Creating permanent PostgreSQL trigger..."
  ActiveRecord::Base.connection.execute(sql_trigger)
  puts "✅ Trigger created successfully!"
  puts ""
rescue => e
  puts "⚠️  Trigger creation failed: #{e.message}"
  puts "   Continuing with database updates..."
  puts ""
end

# 2. Update database configurations
begin
  puts "💾 Updating installation configurations..."

  plan = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN')
  plan.serialized_value = ActiveSupport::HashWithIndifferentAccess.new('value' => 'enterprise')
  plan.locked = true
  plan.save!
  puts "✅ INSTALLATION_PRICING_PLAN: enterprise"

  qty = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')
  qty.serialized_value = ActiveSupport::HashWithIndifferentAccess.new('value' => 9_999_999)
  qty.locked = true
  qty.save!
  puts "✅ INSTALLATION_PRICING_PLAN_QUANTITY: 9999999"

  is_ent = InstallationConfig.find_or_initialize_by(name: 'IS_ENTERPRISE')
  is_ent.value = true
  is_ent.locked = true
  is_ent.save!
  puts "✅ IS_ENTERPRISE: true"
  puts ""

rescue => e
  puts "❌ Database configuration error: #{e.message}"
  puts ""
end

begin
  [
    ['INSTALLATION_PRICING_PLAN', ActiveSupport::HashWithIndifferentAccess.new('value' => 'enterprise')],
    ['INSTALLATION_PRICING_PLAN_QUANTITY', ActiveSupport::HashWithIndifferentAccess.new('value' => 9_999_999)]
  ].each do |name, sval|
    c = InstallationConfig.find_by(name: name)
    next unless c
    c.serialized_value = sval
    c.locked = true
    c.save!
  end
rescue => e
  puts "⚠️  Normalization error: #{e.message}"
end

# 3. Enable Captain features for all accounts (NEW - required for v4.8+)
begin
  puts "🔓 Enabling Captain V1 and V2 features..."

  account_count = 0
  Account.find_each do |account|
    account.enable_features!('captain_integration', 'captain_integration_v2')
    account_count += 1
    puts "  ✅ Account ##{account.id}: #{account.name}"
  end

  puts "✅ Captain enabled for #{account_count} account(s)"
  puts ""

rescue => e
  puts "❌ Feature enablement error: #{e.message}"
  puts ""
end

# 4. Clear Redis cache
begin
  if defined?(Redis::Alfred)
    Redis::Alfred.delete(Redis::Alfred::CHATWOOT_INSTALLATION_CONFIG_RESET_WARNING)
    puts '✅ Redis cache cleared'
  end
rescue => e
  puts "⚠️  Redis error: #{e.message}"
end

# 5. Patch chatwoot_hub.rb fallback values
begin
  possible_paths = [
    '/app/lib/chatwoot_hub.rb',
    '/chatwoot/lib/chatwoot_hub.rb',
    File.join(Rails.root, 'lib', 'chatwoot_hub.rb'),
    './lib/chatwoot_hub.rb'
  ]

  hub_file = possible_paths.find { |path| File.exist?(path) }

  if hub_file
    puts ""
    puts "📁 Patching fallback values in #{hub_file}..."

    # Create backup
    backup_file = "#{hub_file}.backup.#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    FileUtils.cp(hub_file, backup_file)
    puts "💾 Backup: #{backup_file}"

    # Read and update content
    content = File.read(hub_file)
    original = content.dup

    # Update fallbacks
    content.gsub!(
      /(InstallationConfig\.find_by\(name:\s*['"]INSTALLATION_PRICING_PLAN['"]\)&?\.value\s*\|\|\s*)['"]community['"]/,
      "\\1'enterprise'"
    )

    content.gsub!(
      /(InstallationConfig\.find_by\(name:\s*['"]INSTALLATION_PRICING_PLAN_QUANTITY['"]\)&?\.value\s*\|\|\s*)0/,
      "\\19999999"
    )

    if content != original
      File.write(hub_file, content)
      puts "✅ Fallback values updated"
    else
      puts "ℹ️  File already patched"
    end
  end

rescue => e
  puts "⚠️  File patch error: #{e.message}"
end

# 6. Verification
puts ""
puts "🔍 Verification:"

configs = InstallationConfig.where(name: ['INSTALLATION_PRICING_PLAN', 'INSTALLATION_PRICING_PLAN_QUANTITY', 'IS_ENTERPRISE'])
configs.each do |config|
  puts "   • #{config.name}: #{config.value} (locked: #{config.locked})"
end

trigger_check = ActiveRecord::Base.connection.execute(
  "SELECT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_force_enterprise_configs') as exists"
).first

if trigger_check && trigger_check['exists']
  puts "   • PostgreSQL Trigger: ✅ ACTIVE"
else
  puts "   • PostgreSQL Trigger: ⚠️  Not detected"
end

Account.find_each do |account|
  v1 = account.feature_captain_integration? ? '✅' : '❌'
  v2 = account.feature_captain_integration_v2? ? '✅' : '❌'
  puts "   • Account ##{account.id} Captain V1: #{v1} | V2: #{v2}"
end

puts ""
puts "🎉 === Unlock Complete ==="
puts ""
puts "📋 Applied:"
puts "  • Enterprise configurations with permanent trigger protection"
puts "  • Captain V1 (FAQs, Documents, Playground, Inboxes, Settings)"
puts "  • Captain V2 (Scenarios, Tools, Guardrails, Guidelines)"
puts "  • Fallback value patches"
puts ""
puts "🔄 Restart your Chatwoot container to apply all changes"
puts "🌟 Dchat - Educational Project - v4.8+ Edition"
puts ""
