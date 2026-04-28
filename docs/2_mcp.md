# 2. MCP servery

## Co je MCP?

**MCP (Model Context Protocol)** je otevřený protokol od Anthropic, který umožňuje
LLM agentům (Claude Code, Codex apod.) komunikovat s externími nástroji a datovými
zdroji jednotným způsobem. Místo aby měl agent jen své vestavěné nástroje (Read,
Write, Bash...), může se napojit na MCP server a získat tak nové schopnosti — od
čtení dokumentace, přes ovládání prohlížeče, až po práci s databází.

Z pohledu uživatele to vypadá tak, že Claude Code získá další tooly s prefixem
`mcp__<server>__<tool>` (např. `mcp__context7__resolve-library-id`).

## Použité MCP servery v tomto repu

V souboru `.mcp.json` (kořen projektu) je nakonfigurován jeden MCP server:

### Context7

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

**Co umí:** Stáhne aktuální oficiální dokumentaci k libovolné populární knihovně
nebo frameworku — React, Next.js, Tailwind, Prisma, GSAP, Playwright, openpyxl
atd. Užitečné, protože model má znalostní cutoff a dokumentace knihoven se mění.

**Kdy se aktivuje:** Pokud do promptu napíšeš `use context7` a ptáš se na
specifickou knihovnu, agent místo halucinace zavolá tento MCP server a odpoví
podle aktuální dokumentace.

**Příklad:**
```
Napiš mi komponentu v Next.js 15 pro server actions. use context7
```
Agent zavolá `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`
a odpoví podle aktuální dokumentace, ne podle starých znalostí.

## Proč zrovna HTTP server (a ne stdio)

Existují dva typy MCP serverů:

| Typ      | Jak běží                            | Kdy použít                                    |
|----------|-------------------------------------|-----------------------------------------------|
| `stdio`  | Lokální proces (Node, Python...)    | Lokální data, offline tooly, vlastní servery  |
| `http`   | Vzdálený server přes HTTPS          | Cloudové služby, sdílená dokumentace          |

Context7 je hostovaný cloud, proto `http`. Žádná instalace, žádné Node modules.

## Další MCP servery, které se hodí znát (nejsou součástí odevzdání)

- **filesystem** (oficiální) — práce se soubory mimo pracovní adresář
- **github** (oficiální) — REST API GitHubu (issues, PRs, releases)
- **playwright** (Microsoft) — ovládání prohlížeče pro automatizaci a testy
- **sqlite / postgres** — dotazy do databáze

Doplnění je pak otázka přidání další položky do `mcpServers` v `.mcp.json` —
například:
```json
"playwright": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@playwright/mcp@latest"]
}
```
