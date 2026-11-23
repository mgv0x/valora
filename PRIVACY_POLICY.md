# Política de Privacidade — Valora

**Última atualização:** 22 de novembro de 2026  
**Versão:** 1.0  
**Status de Vigência:** Em vigor

---

Bem-vindo ao **Valora** ("nós", "nosso", ou "Aplicativo"). Esta Política de Privacidade explica de forma clara, transparente e acessível como as informações e dados são coletados, utilizados, armazenados, protegidos e compartilhados quando você utiliza o aplicativo móvel **Valora** (disponível para Android e iOS) e a versão **Valora Web**.

O Valora foi concebido sob os princípios de **privacidade por design (Privacy by Design)**, **privacidade por padrão (Privacy by Default)** e **arquitetura prioritariamente local (Offline-first)**. Nosso compromisso central é permitir que você reduza o desperdício alimentar e organize sua despensa com a máxima soberania e controle sobre seus próprios dados, em estrita conformidade com a **Lei Geral de Proteção de Dados do Brasil (Lei nº 13.709/2018 - LGPD)**, o **Regulamento Geral sobre a Proteção de Dados da União Europeia (GDPR - Regulamento UE 2016/679)**, e as diretrizes de privacidade das plataformas **Google Play Store** e **Apple App Store**.

---

## 1. Princípios Fundamentais de Privacidade

1. **Soberania do Usuário (Offline-first):** O aplicativo opera com banco de dados local SQLite no seu aparelho. O uso das funcionalidades fundamentais de cadastro de alimentos, cálculo de validade, registro de consumo/descarte e geração de métricas de impacto não exige conexão com a internet nem cadastro obrigatório.
2. **Zero Rastreamento Invasivo:** Não utilizamos bibliotecas (SDKs) de publicidade direcionada, corretores de dados (data brokers) ou rastreadores de telemetria comportamental de terceiros (como Facebook Pixel, AppsFlyer ou Adjust).
3. **Não Comercialização de Dados:** Jamais vendemos, alugamos, licenciamos ou comercializamos quaisquer dados pessoais ou registros de consumo dos nossos usuários a terceiros.
4. **Minimização e Necessidade:** Apenas coletamos as informações estritamente necessárias para a prestação dos serviços solicitados por você.

---

## 2. Dados Coletados e Formas de Tratamento

O tratamento de dados varia de acordo com o modo de utilização escolhido por você no Valora:

### 2.1. Modo Padrão / Uso Local (Sem Conta na Nuvem)
Quando você utiliza o Valora sem realizar login ou sincronização na nuvem:
- **Dados da Despensa:** Nomes dos alimentos, categorias, quantidades, unidades de medida, datas de validade, datas de compra, preços informados, locais de armazenamento (geladeira, freezer, despensa) e notas adicionais.
- **Histórico de Atividades:** Registros de alimentos consumidos ou descartados, datas e quantidades dessas ações, utilizados para calcular métricas transparentes de economia e sustentabilidade.
- **Lista de Compras:** Itens, quantidades e status de compra adicionados manualmente.
- **Preferências do Aplicativo:** Idioma selecionado, tema visual (claro, escuro ou do sistema), antecedência configurada para alertas de validade (em dias) e preferência de notificações.
- **Onde ficam armazenados:** Exclusivamente na memória protegida (sandbox) do seu dispositivo móvel, em banco de dados SQLite (`valora_inventory.db`) e arquivos de preferências locais (`SharedPreferences` / `UserDefaults`). Nós não temos acesso a esses dados locais.

### 2.2. Modo Conectado / Sincronização em Nuvem (Opcional)
Se você optar por criar uma conta no Valora ou ativar o serviço de sincronização na nuvem (*Cloud Sync*):
- **Dados de Cadastro e Autenticação:** Endereço de e-mail e identificador único de usuário (UID gerado pelo Firebase Authentication). Opcionalmente, nome ou apelido de perfil fornecido voluntariamente por você.
- **Dados de Sincronização e Backup:** Cópia cifrada do seu inventário de alimentos e histórico de consumo/descarte, necessária para permitir a recuperação de dados em caso de troca de aparelho ou uso compartilhado.
- **Status de Assinatura e Indicação:** Indicação de status de assinatura (Gratuito ou Pro), contagem de indicações do programa de recompensas e data de ativação. Não armazenamos números completos de cartão de crédito nem dados bancários (processados por plataformas de pagamento oficiais como Google Play Billing e Apple StoreKit).

### 2.3. Consultas à API Open Food Facts (Opcional)
Ao utilizar a funcionalidade de busca automática de alimentos por nome ou escaneamento de código de barras:
- O termo digitado ou o código de barras lido é enviado em requisição HTTPS para a API pública colaborativa do **Open Food Facts** (`world.openfoodfacts.org`).
- **Nenhum dado pessoal** (como nome, e-mail, geolocalização ou identificador do aparelho) é transmitido nessa requisição. A consulta é anônima e técnica.

---

## 3. Finalidades e Bases Legais do Tratamento (LGPD & GDPR)

De acordo com o Art. 7º da LGPD e o Art. 6º do GDPR, o tratamento dos seus dados fundamenta-se nas seguintes bases legais:

| Finalidade do Tratamento | Dados Envolvidos | Base Legal (LGPD) | Base Legal (GDPR) |
| :--- | :--- | :--- | :--- |
| **Operação da Despensa e Gestão de Validades** | Itens cadastrados, datas de validade, quantidades e categorias | Execução de Contrato (Art. 7º, V) | Execução de Contrato (Art. 6.1.b) |
| **Alertas e Notificações de Vencimento** | Datas de validade de itens específicos | Consentimento (Art. 7º, I) / Legítimo Interesse (Art. 7º, IX) | Consentimento / Legítimo Interesse |
| **Autenticação e Cloud Backup (quando ativado)** | E-mail, senha criptografada, UID do usuário | Execução de Contrato (Art. 7º, V) | Execução de Contrato (Art. 6.1.b) |
| **Pesquisa de Produtos (Open Food Facts)** | Nome do produto ou código de barras pesquisado | Legítimo Interesse / Execução do Serviço | Legítimo Interesse |
| **Exportação e Portabilidade de Dados** | Arquivo JSON com inventário e histórico | Cumprimento de Obrigação Legal (Art. 7º, II) e Direitos do Titular (Art. 18, V) | Obrigação Legal / Portabilidade |

---

## 4. Permissões Solicitadas no Dispositivo

Para oferecer seus recursos com total transparência, o Valora pode solicitar as seguintes permissões no seu sistema operacional (Android / iOS):

1. **Notificações (`POST_NOTIFICATIONS`):**
   - **Finalidade:** Enviar lembretes diários pontuais quando um alimento estiver próximo do vencimento ou vencendo no dia.
   - **Natureza:** As notificações são geradas e agendadas **localmente no próprio sistema operacional do aparelho** (`flutter_local_notifications`). Não enviamos notificações publicitárias nem utilizamos servidores push de marketing.
   - **Controle:** Você pode ativar, desativar ou ajustar o horário e a antecedência de aviso a qualquer momento na tela de **Configurações** do aplicativo ou nas configurações do seu sistema.
2. **Acesso a Arquivos / Armazenamento (`READ/WRITE_EXTERNAL_STORAGE` ou seletor de arquivos do sistema):**
   - **Finalidade:** Utilizada estritamente sob comando explícito do usuário para gravar o arquivo de backup exportado (`valora_backup.json`) ou carregar um arquivo de backup previamente salvo para restauração de dados.
   - **Controle:** O Valora não analisa fotos pessoais, documentos ou outros arquivos alheios ao backup selecionado por você.

---

## 5. Compartilhamento de Dados com Terceiros

O Valora **não compartilha, não vende e não repassa** seus dados pessoais a agências de publicidade, corretores de dados ou parceiros comerciais.

Os únicos compartilhamentos estritamente técnicos ocorrem com provedores de infraestrutura indispensáveis para os recursos ativados por você:
- **Google Firebase (Google LLC):** Provedor de infraestrutura de nuvem, autenticação e armazenamento de dados criptografados para usuários que optam por criar conta e sincronização remota. Os dados são transferidos com criptografia TLS/HTTPS e mantidos em servidores de alta segurança com certificações ISO 27001 e SOC 2.
- **Open Food Facts:** Organização sem fins lucrativos mantenedora da base de dados de alimentos. Apenas recebe a string de texto de consulta de alimentos ou números de código de barras para retorno da ficha nutricional e categoria, sem metadados de identificação pessoal.

---

## 6. Segurança e Armazenamento dos Dados

Empregamos medidas técnicas e organizacionais adequadas para proteger seus dados contra acesso não autorizado, destruição, perda ou alteração:
- **Isolamento de Processos (App Sandbox):** Os dados armazenados localmente residem em diretório privado protegido pelo sistema operacional do seu celular, inacessível a outros aplicativos instalados.
- **Comunicação Criptografada:** Todas as comunicações de rede (como sincronização e buscas de alimentos) utilizam o protocolo criptográfico seguro HTTPS / TLS 1.3.
- **Prevenção de Injeção de Código (SQLi Resilience):** O banco de dados local utiliza consultas parametrizadas rigorosamente auditadas, prevenindo ataques de manipulação de dados.
- **Rotinas de Otimização e Integridade:** O aplicativo oferece recursos de diagnóstico, manutenção (`VACUUM` e `ANALYZE`), reparo de consistência e exportação íntegra de dados.

---

## 7. Retenção e Exclusão de Dados

- **Dados Locais:** Permanecem em seu dispositivo até que você opte por desinstalar o aplicativo, limpar o cache/dados nas configurações do sistema operacional, ou utilizar a opção **"Limpar Todos os Alimentos"** disponível na seção *Dados & Privacidade* do Valora.
- **Exclusão Completa de Conta e Dados em Nuvem:** Usuários cadastrados podem solicitar a exclusão definitiva de sua conta e de todos os dados sincronizados a qualquer momento, diretamente pelas configurações do app ou pelo e-mail de suporte. A exclusão é irreversível e elimina registros de autenticação e backups em até 30 (trinta) dias.

---

## 8. Direitos dos Titulares de Dados (LGPD & GDPR)

Em conformidade com o Artigo 18 da LGPD e as normas do GDPR, você possui os seguintes direitos garantidos em relação aos seus dados:

1. **Confirmação e Acesso:** Saber se tratamos seus dados e acessá-los integralmente a qualquer momento.
2. **Correção:** Retificar dados pessoais inexatos, incompletos ou desatualizados.
3. **Anonimização, Bloqueio ou Eliminação:** Solicitar a eliminação de dados excessivos ou tratados em desconformidade.
4. **Portabilidade:** Exportar livremente todo o seu inventário e histórico de consumo em formato estruturado e legível por máquina (JSON) através da funcionalidade nativa **"Exportar Dados"**.
5. **Revogação do Consentimento:** Revogar permissões a qualquer instante (como desativar notificações ou desconectar a sincronização na nuvem).
6. **Informação sobre Compartilhamento:** Ter clareza sobre com quais entidades técnicas seus dados podem vir a ser compartilhados (conforme detalhado na Seção 5).

---

## 9. Privacidade de Crianças e Adolescentes

O Valora não foi projetado para crianças menores de 13 anos e não coleta intencionalmente dados pessoais de menores. Caso tomemos conhecimento de que dados de menores de 13 anos foram coletados sem consentimento parental comprovado, tomaremos providências imediatas para a eliminação desses dados.

---

## 10. Atualizações desta Política de Privacidade

Podemos atualizar esta Política de Privacidade periodicamente para refletir evoluções do aplicativo, melhorias de segurança ou alterações legislativas. Quando realizarmos modificações substantivas, notificaremos os usuários através de aviso destacado no aplicativo ou atualização da data no topo deste documento. Recomendamos a consulta regular desta página.

---

## 11. Contato e Encarregado de Proteção de Dados (DPO)

Se você tiver dúvidas, sugestões, solicitações de exclusão de dados ou desejar exercer qualquer um dos seus direitos de titular previstos na LGPD, entre em contato conosco:

- **E-mail de Suporte e Privacidade:** `privacidade@valora.app`
- **Responsável pelo Tratamento de Dados:** Equipe de Privacidade Valora
- **Repositório do Projeto:** [github.com/valora/valora](https://github.com/valora/valora)

---
*Valora — Menos desperdício. Mais valor. Soberania total sobre seus dados.*
