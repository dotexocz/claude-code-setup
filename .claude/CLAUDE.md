# CLAUDE.md – claude-code-setup

Tento soubor je projektová verze pravidel pro Claude Code v tomto repu.
Doplňuje (ne nahrazuje) globální `~/.claude/CLAUDE.md`.

## O projektu

Ukázková konfigurace **Claude Code** vytvořená jako odevzdávka pro kurz
**Vibe Coding 1** (Global Classes CZE, 09.04. – 12.05.2026).

Demonstruje použití:
- **MCP serverů** (`.mcp.json`)
- **Skills** (`.claude/skills/`)
- **Subagentů** (`.claude/agents/`)
- **Slash commands** (`.claude/commands/`)
- **Permissions** (`.claude/settings.json`)

Bez závislosti na pluginech a marketplacích, jak vyžaduje zadání kurzu.

## Jazyk komunikace

- **S uživatelem:** česky.
- **Kód a komentáře:** anglicky.
- **Commity:** česky, formát `typ: popis česky` (viz skill `czech-commit-message`).

## Bezpečnost

- Nikdy nezapisuj API klíče, hesla nebo tokeny do kódu.
- Citlivé hodnoty patří do `.env` (ten je v `.gitignore`).
- Nikdy `git commit --no-verify`, `git push --force` na `main`, ani
  `rm -rf` na neznámou cestu.
- Před mazáním vždy spusť skill `safe-delete-check`.

## Code style

- Markdown a YAML soubory: 2 mezery odsazení, žádné taby.
- JSON: standardní 2-mezerové odsazení.
- Jména skillů, agentů a příkazů: kebab-case (`czech-commit-message`,
  ne `czechCommitMessage`).

## Konvence pro skilly v tomto repu

Každý skill žije v samostatné složce `.claude/skills/<jméno>/`.
Hlavní soubor je `SKILL.md` s YAML frontmatter:

```yaml
---
name: <jméno-skillu>
description: <Kdy a proč ho použít — model čte tohle, aby se rozhodl, jestli skill aktivovat.>
---
```

V `description` je důležité **explicitně uvést spouštěcí signály** — slova nebo
situace, kdy se má skill aktivovat. Bez toho ho model nevybere.

## Konvence pro subagenty

Subagent je jeden `.md` soubor v `.claude/agents/<jméno>.md` s frontmatter:

```yaml
---
name: <jméno-agenta>
description: <Kdy ho použít>
tools: Read, Grep, Bash    # whitelist nástrojů, které smí
---
```

Tělo souboru je systémový prompt, který se subagentovi pošle při dispatch.

## Konvence pro slash commands

Slash command je `.md` soubor v `.claude/commands/<jméno>.md`. Volá se jako
`/<jméno>`. Frontmatter:

```yaml
---
description: <Krátký popis pro autocomplete>
allowed-tools: <whitelist nástrojů>
---
```

Tělo je prompt, který Claude Code provede při zavolání příkazu.

## Current Status

_Aktualizováno: 2026-04-28_

**Last done:** Vytvořena kompletní ukázková konfigurace — `.claude/settings.json`,
`.mcp.json` (Context7), 3 skilly, 2 subagenti, 2 slash commands. Repo
nasazeno na GitHub.

**Next:**
- Otevřít projekt v Claude Code a otestovat, že se všechny komponenty
  načtou (`/skills`, `/agents`, `/stav`).
- Odevzdat odkaz na repo do školního systému před deadlinem **8. 5. 2026 23:59**.

**Known issues:** žádné
