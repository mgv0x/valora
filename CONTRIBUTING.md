# Guia de Contribuição e Desenvolvimento — Valora

Obrigado pelo seu interesse em contribuir com o **Valora**! O Valora é um projeto de código aberto focado no controle de alimentos e prevenção do desperdício doméstico.

---

## 🛠 Requisitos de Ambiente

- **Flutter SDK**: 3.22.x ou superior (compatível com Dart 3.4+)
- **OS**: Windows, macOS ou Linux
- **SQLite**: Suportado nativamente via `sqflite` (mobile) e `sqflite_common_ffi` (desktop).

---

## 🚀 Como Executar o Projeto

```bash
# 1. Obter dependências do Flutter
flutter pub get

# 2. Gerar arquivos de localização (i18n)
flutter gen-l10n

# 3. Executar em modo de desenvolvimento (Chrome ou Desktop)
flutter run -d chrome
# ou
flutter run -d windows
```

---

## 🧪 Rodando os Testes Automatizados

O Valora mantém um padrão de teste rigoroso para garantir zero regressões na lógica de despensa, expiração de alimentos e persistência offline.

```bash
# Rodar todos os testes automatizados da suíte
flutter test

# Rodar análise estática de código
flutter analyze
```

### Principais Suítes de Testes:
- `test/domain_expiry_test.dart`: Regras e enums de status de expiração (`expired`, `expiringToday`, `expiringSoon`, `fresh`, `unknownExpiry`).
- `test/domain_food_lifecycle_test.dart`: Ciclo de vida das quantidades, consumo e descarte.
- `test/persistence_sqlite_test.dart`: Operações CRUD e transações atômicas no repositório SQLite.
- `test/session4_settings_notifications_release_test.dart`: Testes das configurações, notificações locais e backup JSON.

---

## 📐 Padrões de Código e Diretrizes

1. **Acessibilidade e Usabilidade**:
   - Forneça rótulos semânticos e estados visuais claros para botões, filtros e campos.
   - Trate sempre estados vazios (`EmptyStateView`) com ilustrações ou mensagens amigáveis.
2. **Offline-First & Transações**:
   - Qualquer mutação no banco de dados SQLite que envolva múltiplas tabelas (ex: consumir alimento + gerar histórico) DEVE utilizar transações ACID (`db.transaction`).
3. **Internacionalização**:
   - Nunca coloque strings hardcoded na interface de usuário.
   - Adicione novas chaves de texto em `lib/l10n/app_pt.arb` e `lib/l10n/app_en.arb`, e execute `flutter gen-l10n`.
4. **Sem Dependências Desnecessárias**:
   - Evite adicionar pacotes no `pubspec.yaml` sem discussão prévia. Dê preferência aos componentes nativos do Flutter e `Provider`.

---

## 📑 Processo de Pull Request

1. Crie uma branch com nome descritivo (`feature/nome-da-feature` ou `fix/nome-do-bug`).
2. Garanta que `flutter analyze` não retorne alertas nem erros.
3. Garanta que todos os testes (`flutter test`) estejam passando.
4. Abra o Pull Request descrevendo claramente o problema resolvido e as mudanças realizadas.
