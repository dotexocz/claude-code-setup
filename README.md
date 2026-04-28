# Claude Code – ukázková konfigurace

Odevzdávka pro kurz **Vibe Coding 1** (Global Classes CZE,
[Vibe-Coding-1](https://github.com/Global-Classes-CZE/Vibe-Coding-1)).

Demonstruje, jak rozšířit [Claude Code](https://docs.claude.com/en/docs/claude-code/overview)
o vlastní **MCP servery**, **skilly**, **subagenty** a **slash commands** —
**bez** použití pluginů a marketplaců.

---

## Co je v tomto repu

| Cesta                                      | Co to dělá                                              |
|--------------------------------------------|---------------------------------------------------------|
| `.claude/settings.json`                    | Pravidla, co Claude smí a co nesmí (allow / deny)        |
| `.claude/CLAUDE.md`                        | Projektový systémový prompt — pravidla a stav projektu  |
| `.mcp.json`                                | Konfigurace MCP serverů (zde: Context7)                 |
| `.claude/skills/`                          | Tři vlastní skilly                                      |
| `.claude/agents/`                          | Dva vlastní subagenti                                   |
| `.claude/commands/`                        | Dva vlastní slash commands                              |
| `docs/`                                    | Vysvětlující dokumentace v češtině                      |

```
claude-code-setup/
├── README.md                            ← tento soubor
├── .gitignore
├── .mcp.json                            ← MCP servery
├── .claude/
│   ├── settings.json                    ← permissions
│   ├── CLAUDE.md                        ← projektový prompt + Current Status
│   ├── skills/
│   │   ├── czech-commit-message/SKILL.md
│   │   ├── safe-delete-check/SKILL.md
│   │   └── project-status-update/SKILL.md
│   ├── agents/
│   │   ├── czech-code-reviewer.md
│   │   └── docs-writer-cs.md
│   └── commands/
│       ├── stav.md                      ← /stav
│       └── zavrit-sezeni.md             ← /zavrit-sezeni
└── docs/
    ├── 1_settings.md
    ├── 2_mcp.md
    ├── 3_skills.md
    ├── 4_subagents.md
    └── 5_commands.md
```

---

## Rychlý přehled obsahu

### MCP servery (`.mcp.json`)

- **Context7** (HTTP) – stahuje aktuální dokumentaci knihoven
  (React, Next.js, Tailwind, Prisma, Playwright, openpyxl, …).
  Aktivuje se napsáním `use context7` do promptu.

→ podrobně: [`docs/2_mcp.md`](docs/2_mcp.md)

### Skilly (`.claude/skills/`)

| Skill                        | K čemu                                                         |
|------------------------------|----------------------------------------------------------------|
| `czech-commit-message`       | Generuje Conventional Commit zprávu v češtině                  |
| `safe-delete-check`          | Před každým mazáním vypíše seznam a počká na potvrzení         |
| `project-status-update`      | Aktualizuje sekci `## Current Status` v `CLAUDE.md`            |

→ podrobně: [`docs/3_skills.md`](docs/3_skills.md)

### Subagenti (`.claude/agents/`)

| Subagent                     | K čemu                                                         |
|------------------------------|----------------------------------------------------------------|
| `czech-code-reviewer`        | Review kódu v češtině pro začátečníka                          |
| `docs-writer-cs`             | Píše české README a dokumentaci                                |

→ podrobně: [`docs/4_subagents.md`](docs/4_subagents.md)

### Slash commands (`.claude/commands/`)

| Příkaz             | Co dělá                                                              |
|--------------------|----------------------------------------------------------------------|
| `/stav`            | Zobrazí stav projektu — větev, rozpracováno, posledních 5 commitů    |
| `/zavrit-sezeni`   | Ukončí session: aktualizuje Current Status, navrhne commit, push     |

→ podrobně: [`docs/5_commands.md`](docs/5_commands.md)

---

## Jak to vyzkoušet

1. **Naklonuj repo:**
   ```bash
   git clone https://github.com/dotexocz/claude-code-setup.git
   cd claude-code-setup
   ```

2. **Otevři v Claude Code:**
   ```bash
   claude
   ```
   Claude Code automaticky načte `.claude/` z aktuálního adresáře (skilly,
   agenty, commands) a `.mcp.json` se zeptá na povolení MCP serveru.

3. **Vyzkoušej slash command:**
   ```
   /stav
   ```

4. **Vyzkoušej skill** (Claude ho aktivuje automaticky podle popisu, nebo
   ho můžeš zavolat ručně):
   ```
   Vytvoř commit message pro aktuální změny.
   ```

5. **Vyzkoušej subagenta:**
   ```
   Spusť czech-code-reviewer nad poslední změnou.
   ```

---

## Proč bez pluginů a marketplace

Zadání kurzu výslovně vyžaduje, aby konfigurace byla postavená **jen na
nativních mechanismech** Claude Code (settings.json, MCP, skills, agents,
commands). Pluginy by skryly podstatu — všechen obsah skillů, subagentů
a příkazů je v tomto repu **přímo viditelný a editovatelný**.

V praxi se po odevzdání samozřejmě dají kombinovat oba přístupy: pluginy
pro hotová řešení (Anthropic official, komunitní marketplaces) + vlastní
skilly a agenti pro projekt-specifická pravidla.

---

## Použití pro vlastní projekt

Pokud si chceš tuhle konfiguraci přenést do vlastního projektu:

1. Zkopíruj složku `.claude/` a soubor `.mcp.json` do svého projektu.
2. Uprav `.claude/CLAUDE.md` podle svého projektu (sekce "O projektu",
   "Code style", "Current Status").
3. Edituj `description` skillů a agentů, ať odpovídají tvému workflow.
4. Pokud máš nový MCP server, doplň ho do `.mcp.json`.

---

## Autor

Lukáš Melichar – kurz Vibe Coding 1, 04/2026

Repo: <https://github.com/dotexocz/claude-code-setup>
