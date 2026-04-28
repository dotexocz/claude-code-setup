# 2. MCP servery

## Co je MCP?

**MCP (Model Context Protocol)** je otevřený protokol od Anthropic, který umožňuje
LLM agentům (Claude Code, Codex apod.) komunikovat s externími nástroji a datovými
zdroji jednotným způsobem. Místo aby měl agent jen své vestavěné nástroje (Read,
Write, Bash...), může se napojit na MCP server a získat tak nové schopnosti — od
čtení dokumentace, přes ovládání prohlížeče, až po práci s databází.

Z pohledu uživatele to vypadá tak, že Claude Code získá další tooly s prefixem
`mcp__<server>__<tool>` (např. `mcp__context7__resolve-library-id`).

## Typy MCP serverů

| Typ              | Jak běží                            | Kdy použít                                         |
|------------------|-------------------------------------|----------------------------------------------------|
| `stdio`          | Lokální proces (Node, Python, …)    | Lokální nástroje (filesystem, browser, vlastní)    |
| `http`           | Vzdálený HTTPS server               | Cloudové API, sdílené služby                        |
| `sse`            | Server-Sent Events (legacy stream)  | Stejný jako http, postupně se opouští             |

## MCP servery v tomto repu

V `.mcp.json` (kořen projektu) jsou tři:

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    },
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

### 1. Context7 (HTTP)

**Co umí:** Stáhne aktuální oficiální dokumentaci k libovolné populární knihovně
nebo frameworku — React, Next.js, Tailwind, Prisma, GSAP, Playwright, openpyxl
atd. Užitečné, protože model má znalostní cutoff a dokumentace knihoven se mění.

**Kdy se aktivuje:** Pokud do promptu napíšeš `use context7` a ptáš se na
specifickou knihovnu, agent místo halucinace zavolá tento MCP server a odpoví
podle aktuální dokumentace.

**Příklad použití:**
```
Napiš mi komponentu v Next.js 15 pro server actions. use context7
```
Agent zavolá `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`
a odpoví podle aktuální dokumentace, ne podle starých znalostí.

**Konfigurace:** Veřejný hostovaný server, žádný token nepotřebuje. Stačí URL.

### 2. Playwright (stdio)

**Co umí:** Ovládání prohlížeče — otevírání stránek, klikání, vyplňování
formulářů, screenshoty, scraping, generování test kódu. Skvělé na
end-to-end testování a automatizaci webů.

**Co spustí:** `npx -y @playwright/mcp@latest` — `npx` stáhne (pokud není v
cachi) Playwright MCP server od Microsoftu a spustí ho jako lokální stdio
proces.

**První spuštění:** Trvá déle (`npx` musí stáhnout balík). Pro rychlejší
opakované použití nainstaluj globálně:
```bash
npm install -g @playwright/mcp
npx playwright install chromium       # stáhnout Chromium
```

**Užitečné nástroje, které se objeví v Claude:**
- `mcp__playwright__browser_navigate`
- `mcp__playwright__browser_snapshot` (struktura stránky pro AI)
- `mcp__playwright__browser_click`
- `mcp__playwright__browser_type`
- `mcp__playwright__browser_take_screenshot`

**Příklad použití:**
```
Otevři evamamacafe.cz, najdi formulář a vyplň testovací data.
```

### 3. GitHub (HTTP)

**Co umí:** Práce s GitHub API — issues, pull requesty, branching, releases,
analýza kódu, workflows. To, co dělá `gh` CLI, akorát z prostředí Claude.

**Co spustí:** Nic lokálně — je to vzdálený server hostovaný GitHubem na
`https://api.githubcopilot.com/mcp/`. Claude Code se k němu připojí
HTTPS streamem.

**Autentizace:** Vyžaduje **GitHub Personal Access Token** v hlavičce
`Authorization`. V `.mcp.json` je hodnota `Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}`
— Claude Code substituuje proměnnou prostředí. Takže token je v `.env`,
ne v gitem verzovaném `.mcp.json`.

**Jak získat token:**

1. Jdi na <https://github.com/settings/personal-access-tokens>.
2. Klikni **Generate new token** → **Fine-grained token**.
3. **Resource owner:** tvůj uživatel.
4. **Repository access:** *Only select repositories* (vyber, na které chceš
   Claude pouštět).
5. **Permissions** (alespoň):
   - Contents → **Read**
   - Issues → **Read and write**
   - Pull requests → **Read and write**
   - Metadata → **Read** (povinné)
6. Vygeneruj token a vlož do `.env`:
   ```
   GITHUB_PERSONAL_ACCESS_TOKEN=github_pat_…
   ```
7. Restartuj Claude Code, ať si proměnnou načte.

**Důležité:** **Nikdy** netluč token do `.mcp.json` přímo. Zůstal by v gitu.
Vždy přes `${VAR}` substituci.

**Užitečné nástroje:**
- `mcp__github__list_issues`
- `mcp__github__create_pull_request`
- `mcp__github__search_code`
- `mcp__github__merge_pull_request`

## Alternativa GitHub MCP přes Docker

Pokud nechceš používat hostovaný server (např. citlivá data, on-prem
GitHub Enterprise), GitHub publikuje Docker image:

```json
"github": {
  "type": "stdio",
  "command": "docker",
  "args": [
    "run", "-i", "--rm",
    "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
    "ghcr.io/github/github-mcp-server"
  ],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
  }
}
```

V tomto repu jsem zvolil HTTP variantu — je o krok jednodušší (žádný
Docker), což pro výuku stačí.

## Hierarchie MCP konfigurace

Claude Code načítá MCP servery ze tří míst:

1. **Globální** — `~/.claude/settings.json` v `mcpServers`
2. **Projektový** — `<projekt>/.mcp.json` (tento repo)
3. **Lokální** — `~/.claude/projects/<hash>/settings.local.json` (osobní override)

Při startu se vždycky zeptá uživatele, jestli má přidaný MCP server
schválit (kvůli bezpečnosti — MCP server vidí výstupy nástrojů a může je
posílat dál).

## Bezpečnostní poznámky

- **MCP server vidí to, co mu pošleš.** Než přidáš cizí MCP server, přečti
  si, co dělá. Stejný kalibr důvěry jako u VS Code rozšíření.
- **Tokeny vždycky přes env**, nikdy ne v `.mcp.json`. Pokud token "ucucne"
  do gitu, hned ho **rotuj** (smaž a vytvoř nový).
- **Fine-grained tokeny** (na konkrétní repa) jsou bezpečnější než classic
  PATy.
- **Public MCP servery** (jako Context7, GitHub Copilot MCP) loguji
  requesty — neposílej tam citlivá data.

## Další MCP servery, které stojí za zvážení

- **filesystem** (oficiální) – práce se soubory mimo pracovní adresář
- **postgres / sqlite** – přímé dotazy do databáze
- **memory** – persistentní paměť napříč sezeními
- **slack / linear / notion** – napojení na týmové nástroje

Doplnění je vždy o jednu položku v `mcpServers` v `.mcp.json`.
