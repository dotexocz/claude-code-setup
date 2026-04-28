# Bezpečnost a rozsah projektu

## Co tento repozitář **je**

Ukázková konfigurace **Claude Code** — odevzdávka pro kurz Vibe Coding 1.
Jejím cílem je demonstrovat strukturu vlastních skills, subagentů, slash
commands, hooks a MCP serverů.

## Co tento repozitář **není**

- Není to produkční konfigurace.
- Neobsahuje žádné reálné API klíče, tokeny ani citlivé údaje.
- Není auditován pro nasazení mimo demo.

## Co bych měl/-a vědět, než si tohle stáhnu

### 1. `.env.example` je šablona, **ne** funkční konfigurace

Všechny hodnoty v `.env.example` jsou pouze placeholdery
(`GITHUB_PERSONAL_ACCESS_TOKEN=` bez hodnoty). Než cokoliv spustíš,
vytvoř si **vlastní** `.env` se svými klíči. Nikdy ten soubor necommituj
zpět do gitu — `.gitignore` ho už filtruje, ale ujisti se.

### 2. PostToolUse hook (`log-edits.sh`) loguje cesty k souborům

Hook zapisuje do `.claude/edits.log` cesty každého upraveného souboru.
Pokud bys repo nasazoval/-a ve sdíleném prostředí (kontejner, server,
sdílený notebook), `.claude/edits.log` může obsahovat citlivé cesty.
`.gitignore` ho filtruje, ale stejně si pohlídej.

### 3. MCP servery jsou externí závislosti

- **Context7** — odesílá tvé dotazy na `mcp.context7.com`. Neposílej tam
  proprietární kód ani citlivé dotazy.
- **Playwright** — spouští plnohodnotný browser; návštěva stránek může
  ukládat cookies. Pro citlivé scénáře zvaž `--isolated` flag.
- **GitHub MCP** — vyžaduje token. Použij **fine-grained** PAT s povolením
  jen na konkrétní repa, ne classic token.

### 4. Skilly a subagenti běží s tvými právy

Jakýkoliv skill, subagent nebo command, který si nainstaluješ z cizího
zdroje, běží **s plnými právy tvého terminálu**. Nikdy je nepřebírej
naslepo — projdi si SKILL.md / agent.md, podívej se, co dělají.

V tomto repu jsou všechny skripty otevřené a přečteš je za pár minut.

## Hlášení bezpečnostních problémů

Pokud najdeš v tomhle repu něco, co považuješ za bezpečnostní díru,
otevři issue na GitHubu nebo napiš.
