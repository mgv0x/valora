# PROJETO INFINITO — RELATÓRIO DE ENGENHARIA E AUDITORIA CONTÍNUA
*Projeto Real Auditado e Evoluído:* **Valora** (`dev.hackclub.valora.valora`)  
*Contexto:* Aplicação móvel e desktop desenvolvida em Flutter / Dart para gestão de despensa, redução de desperdício alimentar e rastreabilidade de validade (100% offline-first, sem dependências de nuvem ou intermediários).  
*Data de Execução:* 11 de outubro de 2026

---

## 1. Identificação Real do Repositório e Configuração Técnica

- **Linguagem & Framework:** Dart SDK `^3.12.2` / Flutter `3.44.9`.
- **Raiz do Projeto:** `c:\valora`.
- **Plataformas Configuradas:** Android, iOS, Windows, Web.
- **Configuração Android:**
  - `applicationId`: `dev.hackclub.valora.valora`
  - `minSdk`: Flutter minSdk (API 21+)
  - `targetSdk`: Flutter targetSdkVersion (API 34+)
  - `compileSdk`: Flutter compileSdkVersion (API 34+)
  - Permissões declaradas: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`.
- **Monetização e Privacidade:**
  - Inspecionados `pubspec.yaml`, `build.gradle.kts` e árvore `lib/`.
  - **Zero SDKs de publicidade** (sem Google Mobile Ads, Unity Ads ou rastreadores de terceiros).
  - **Zero telemetria externa**: Todos os dados são mantidos localmente na base relacional SQLite (`sqflite`).

---

## 2. Linha de Base e Evolução dos Ciclos de Engenharia

| Métrica / Etapa | Linha de Base Inicial | Fim da Rodada Titã | Fim da Rodada Ômega | **Fim da Rodada Infinito** |
| :--- | :---: | :---: | :---: | :---: |
| Testes Unitários e Widget | 84 passando / 3 falhando | 87 passando / 0 falhando | 88 passando / 0 falhando | **98 passando / 0 falhando (100%)** |
| Diagnósticos do Linter (`flutter analyze`) | 5 avisos | 0 avisos | 0 avisos | **0 avisos (`No issues found!`)** |
| Determinismo Temporal | Dependência do relógio real | Parcial | Completo com `referenceDate` | **100% Validado em todas as camadas** |
| Integridade de Importação/Exportação | Sem validação em mocks | Em SQLite | Sincronizado c/ Alarmes | **Validado contra corrupção e payloads inválidos** |
| Resiliência de Moedas/Locales | Frágil a formatos inválidos | Inalterado | Inalterado | **Blindado com fallback defensivo para USD/en_US** |

---

## 3. Problemas Confirmados e Soluções Implementadas

### A. Determinismo Temporal e Resolução de Falhas em Testes
- **Causa Raiz:** O cálculo de status de expiração (`getExpiryStatus`) e o agrupamento da Central de Validades em `PantryProvider` chamavam internamente `DateTime.now()`, causando quebras intermitentes em suítes com dados sintéticos fixados.
- **Solução Implementada:** Injeção de `referenceDate` opcional no construtor e através do método `setReferenceDate()` em [`lib/state/pantry_provider.dart`](file:///c:/valora/lib/state/pantry_provider.dart). Todos os getters de prioridade alimentar e agrupamento delegam o `referenceDate`.

### B. Resiliência de Moedas e Locales
- **Causa Raiz:** [`lib/core/utils/currency_formatter.dart`](file:///c:/valora/lib/core/utils/currency_formatter.dart) invocava diretamente `NumberFormat.simpleCurrency(locale: locale)`. Qualquer código de locale malformado ou desconhecido lançado pelo sistema operacional disparava exceções não tratadas.
- **Solução Implementada:** Envolvido em bloco defensivo `try/catch` com fallback automático e gracioso para `en_US` sem quebrar a renderização da interface.

### C. Alinhamento Contratual em Mock Repositories e Importação Atômica
- **Causa Raiz:** O [`test/mocks/in_memory_food_repository.dart`](file:///c:/valora/test/mocks/in_memory_food_repository.dart) aceitava objetos com erros de validação durante o `importData`, diferindo do comportamento transacional estrito do `SqliteFoodRepository`.
- **Solução Implementada:** Implementada verificação item a item com `item.validate()`, assegurando paridade contratual rigorosa entre testes em memória e produção SQLite.

### D. Notificações Órfãs e Sincronização pós-Restauração
- **Causa Raiz:** Importar um backup não re-sincronizava os alarmes do sistema; limpar os dados deixava alarmes previamente agendados na bandeja do sistema operacional.
- **Solução Implementada:** Integradas chamadas a `rescheduleAllExpiryWarnings()` pós-import e `cancelAll()` na limpeza total em [`lib/presentation/screens/settings/settings_screen.dart`](file:///c:/valora/lib/presentation/screens/settings/settings_screen.dart).

### E. Blindagem de Parsing Numérico em Telas de Cadastro
- **Causa Raiz:** `double.parse` nos formulários podia causar crashes caso o usuário inserisse caracteres inesperados.
- **Solução Implementada:** Substituído por `double.tryParse` com valores padrão seguros (`1.0` para quantidade, `null` para preço opcional) em [`lib/presentation/screens/food_form/add_edit_food_screen.dart`](file:///c:/valora/lib/presentation/screens/food_form/add_edit_food_screen.dart).

---

## 4. Nova Suíte de Testes Adicionada

- Arquivo: [`test/session5_resilience_and_math_test.dart`](file:///c:/valora/test/session5_resilience_and_math_test.dart) (10 novos testes):
  1. *Gracefully formats null as empty string*
  2. *Formats valid positive, zero, and negative values with default USD*
  3. *Formats with custom locale pt_BR*
  4. *Handles malformed or unrecognized locale codes without throwing*
  5. *Rejects import when app identifier is missing or mismatched*
  6. *Rejects import when food_items payload is missing*
  7. *Rejects import containing items with invalid business invariants*
  8. *Atomically replaces dataset upon valid import*
  9. *Calculates proportional values with floating-point stability*
  10. *Returns null proportional value when purchase price is not set*

---

## 5. Auditoria Adversarial e Evidências Reais de Execução

- **Comando:** `& "C:\flutter\bin\flutter.bat" test`  
  **Resultado:** **00:06 +98: All tests passed!** (100% de sucesso).
- **Comando:** `& "C:\flutter\bin\flutter.bat" analyze`  
  **Resultado:** **No issues found! (ran in 1.6s)** (0 erros, 0 warnings, 0 lints).
- **Integridade do Repositório Git:** Nenhum comando destrutivo foi executado; o histórico e arquivos de trabalho permanecem intactos e organizados.
