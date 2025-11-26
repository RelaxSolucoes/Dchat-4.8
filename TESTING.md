# Passo a Passo para Testar o Script

## 🎯 Objetivo

Testar o script `unlock_captain_v4.8.rb` em um ambiente limpo para garantir que funciona 100% antes de usar em produção.

## 📋 Pré-requisitos

- Stack Chatwoot rodando
- Acesso ao Portainer ou Docker CLI
- Backup atual (opcional, mas recomendado)

## 🧪 Processo de Teste

### Passo 1: Parar a Stack

**No Portainer:**
1. Vá em `Stacks`
2. Selecione sua stack do Chatwoot
3. Clique em `Stop this stack`
4. Aguarde todos os containers pararem

**Ou via CLI:**
```bash
docker stack rm chatwoot_chatwoot
```

### Passo 2: Resetar o Banco de Dados

**Entre no container PostgreSQL:**
```bash
docker exec -it <nome_container_postgres> bash
```

**Termine as sessões ativas e recrie o banco:**
```bash
psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'chatwoot' AND pid <> pg_backend_pid();"
psql -U postgres -c "DROP DATABASE chatwoot;"
psql -U postgres -c "CREATE DATABASE chatwoot;"
```

**Saia do container:**
```bash
exit
```

### Passo 3: Subir a Stack Novamente

**No Portainer:**
1. Clique em `Start this stack`
2. Aguarde todos os containers subirem completamente

**Ou via CLI:**
```bash
docker stack deploy -c minha_stack_chatwoot.yaml chatwoot_chatwoot
```

### Passo 4: Aguardar Inicialização

Aguarde até que o Chatwoot termine de inicializar:
- Acesse a URL do Chatwoot
- Crie sua conta/faça login
- Confirme que o sistema está funcionando

### Passo 5: Verificar Estado Inicial

**Verifique se Captain NÃO está disponível:**
1. Acesse o Chatwoot
2. O menu Captain NÃO deve aparecer OU deve mostrar paywall

**Verifique configurações no banco (opcional):**
```bash
docker exec -it <chatwoot_container> bundle exec rails runner "
  puts 'INSTALLATION_PRICING_PLAN: ' + (InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')&.value || 'não existe').to_s
  puts 'Captain V1: ' + Account.first.feature_captain_integration?.to_s
  puts 'Captain V2: ' + Account.first.feature_captain_integration_v2?.to_s
"
```

Deve mostrar:
- `INSTALLATION_PRICING_PLAN: community` ou `não existe`
- `Captain V1: false`
- `Captain V2: false`

### Passo 6: Executar o Script

**Entre no container do Chatwoot:**
```bash
docker exec -it <chatwoot_container> bash
```

**Execute o script via wget:**
```bash
wget -qO- https://raw.githubusercontent.com/RelaxSolucoes/Dchat-4.8/main/unlock_captain_v4.8.rb | bundle exec rails runner -
```

**Aguarde a execução completar.**

### Passo 7: Verificar Saída do Script

A saída deve mostrar:

```
🚀 === Dchat Captain - Complete Unlock for v4.8+ ===

📊 Creating permanent PostgreSQL trigger...
✅ Trigger created successfully!

💾 Updating installation configurations...
✅ INSTALLATION_PRICING_PLAN: enterprise
✅ INSTALLATION_PRICING_PLAN_QUANTITY: 9999999
✅ IS_ENTERPRISE: true

🔓 Enabling Captain V1 and V2 features...
  ✅ Account #1: [Nome da Conta]
✅ Captain enabled for 1 account(s)

✅ Redis cache cleared

📁 Patching fallback values in /app/lib/chatwoot_hub.rb...
💾 Backup: /app/lib/chatwoot_hub.rb.backup.YYYYMMDD_HHMMSS
✅ Fallback values updated

🔍 Verification:
   • INSTALLATION_PRICING_PLAN: enterprise (locked: true)
   • INSTALLATION_PRICING_PLAN_QUANTITY: 9999999 (locked: true)
   • IS_ENTERPRISE: true (locked: true)
   • PostgreSQL Trigger: ✅ ACTIVE
   • Account #1 Captain V1: ✅ | V2: ✅

🎉 === Unlock Complete ===
```

### Passo 8: Reiniciar o Container

```bash
exit  # Sair do container
docker restart <chatwoot_container>
```

### Passo 9: Testar no Navegador

1. **Aguarde 1-2 minutos** para o container reiniciar completamente
2. **Acesse o Chatwoot** no navegador
3. **Faça login** (se necessário)
4. **Verifique o menu Captain:**
   - Deve aparecer no menu lateral
   - Deve mostrar **7 submenus**:
     - FAQs
     - Documentos
     - Cenários
     - Playground
     - Caixas de Entrada
     - Ferramentas
     - Configurações

5. **Teste criar um assistente:**
   - Clique em qualquer submenu do Captain
   - NÃO deve aparecer paywall
   - Deve permitir criar/editar assistentes

### Passo 10: Verificação Final

**Verifique as configurações:**
```bash
docker exec -it <chatwoot_container> bundle exec rails runner "
  puts '=== Configurações ==='
  puts 'PLAN: ' + InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN').value.to_s
  puts 'QTY: ' + InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').value.to_s
  puts 'ENTERPRISE: ' + InstallationConfig.find_by(name: 'IS_ENTERPRISE').value.to_s
  puts ''
  puts '=== Features ==='
  Account.find_each do |a|
    puts \"Account ##{a.id}: V1=#{a.feature_captain_integration?} | V2=#{a.feature_captain_integration_v2?}\"
  end
"
```

Deve mostrar:
- `PLAN: enterprise`
- `QTY: 9999999`
- `ENTERPRISE: true`
- `Account #1: V1=true | V2=true`

## ✅ Critérios de Sucesso

O teste é considerado **bem-sucedido** se:

- ✅ Script executou sem erros
- ✅ Trigger PostgreSQL foi criado
- ✅ Configurações enterprise foram aplicadas
- ✅ Features Captain V1 e V2 foram habilitadas
- ✅ Menu Captain aparece com 7 submenus
- ✅ Nenhum paywall aparece ao acessar Captain
- ✅ É possível criar/editar assistentes

## ❌ Possíveis Problemas

### Script dá erro de trigger

**Erro:** `PG::DatatypeMismatch: ERROR: could not determine polymorphic type`

**Solução:** O trigger bugado do unlock_permanent.rb original está instalado. Remova-o:
```bash
docker exec -it <postgres_container> psql -U postgres -d chatwoot -c \
  "DROP TRIGGER IF EXISTS trg_force_enterprise_configs ON installation_configs; \
   DROP FUNCTION IF EXISTS force_enterprise_installation_configs();"
```

Execute o script novamente.

### Só aparecem 3 menus

**Causa:** Captain V2 não foi habilitado.

**Solução:** Execute manualmente:
```bash
docker exec -it <chatwoot_container> bundle exec rails runner \
  "Account.find_each { |a| a.enable_features!('captain_integration_v2') }"
```

### Menu não aparece após reiniciar

**Causa:** Cache do navegador.

**Solução:**
1. Limpe o cache do navegador (Ctrl+Shift+Delete)
2. Ou acesse em modo anônimo
3. Faça hard refresh (Ctrl+F5)

## 🔄 Testar Persistência

Para garantir que é realmente permanente:

1. **Reinicie o container** novamente
2. **Verifique** se Captain continua aparecendo
3. **Tente desabilitar** via Super Admin → Account Features → Captain
4. **Recarregue** a página
5. **Captain deve continuar ativo** (trigger protege)

## 📝 Documentar Resultado

Após testar, documente:
- ✅ Versão do Chatwoot testada
- ✅ Sistema operacional do servidor
- ✅ Tipo de instalação (Docker, Portainer, etc)
- ✅ Problemas encontrados (se houver)
- ✅ Screenshots dos 7 menus

## 🎯 Próximos Passos

Se o teste foi **bem-sucedido**:
1. Documente o processo
2. Crie um ambiente de produção separado
3. Teste novamente em produção antes de usar com clientes
4. Mantenha backups regulares

Se o teste **falhou**:
1. Documente o erro exato
2. Verifique os logs: `docker logs <chatwoot_container>`
3. Abra uma issue no repositório com detalhes
