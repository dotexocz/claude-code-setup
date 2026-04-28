# 5. Slash commands (`.claude/commands/`)

## Co je slash command

**Slash command** je uživatelem volaná zkratka. Píše se `/<jmeno>` v promptu.
Když ho uživatel napíše, Claude Code načte soubor `.claude/commands/<jmeno>.md`
a jeho obsah pošle jako prompt.

To je rozdíl proti skillu (Claude rozhoduje sám, jestli použít) a subagentovi
(volá ho jiný agent, ne uživatel).

## Anatomie slash commandu

```yaml
---
description: <Krátký popis pro autocomplete>
allowed-tools: <whitelist nástrojů, čárkami oddělené>
---

Tělo příkazu. Píše se v perspektivě "Claude, udělej tohle:".
Tady patří všechen návod, co a jak provést.
```

`description` je důležitý — uživatel ho uvidí v autocomplete, když začne
psát `/`.

`allowed-tools` omezí, co příkaz smí. Pokud chybí, dědí z hlavní session.

## Slash commands v tomto repu

### `/stav`

**Co dělá:** Krátký přehled, kde jsme v projektu.

```
## Stav projektu

**Větev:** main
**Rozpracováno:** 3 souborů upravených, 1 untracked

**Posledních 5 commitů:**
- a3f9e21 feat: napiš slash commands
- f8a23b1 feat: vytvoř subagenty czech-code-reviewer a docs-writer-cs
- 4d12b87 feat: vytvoř 3 vlastní skilly
- ...

**Z CLAUDE.md (Current Status):**
Last done: ...
Next: ...
```

**Proč:** Po návratu k projektu po několika dnech není zřejmé, kde jsi
skončil. `/stav` to zobrazí během vteřiny.

**Whitelist:** `Bash(git status)`, `Bash(git log:*)`, `Bash(git diff --stat:*)`,
`Bash(git branch --show-current)`, `Read`, `Glob`. Žádný `Write` — příkaz
nikdy nic nemění.

### `/zavrit-sezeni`

**Co dělá:** Pomůže ukončit pracovní session — aktualizuje Current Status,
navrhne commit message, připomene push.

Postupně volá:

1. **Skill `project-status-update`** — aktualizuje sekci v `CLAUDE.md`.
2. **Skill `czech-commit-message`** — vygeneruje návrh commit message.
3. Spočítá, jestli jsou nepushnuté commity — pokud ano, řekne uživateli,
   ať pustí `git push`.

Sám push **neprovede** (globální pravidlo "nikdy nepushuj na main bez
explicitního příkazu").

**Whitelist:** Read-only git příkazy + `Read`, `Edit`, `Skill`. Žádný
`Bash(git push:*)` ani `Bash(git commit:*)` — uživatel rozhoduje.

## Jak slash command napsat

1. **Vytvoř soubor** v `.claude/commands/<jmeno>.md`.
2. **Frontmatter** s `description` (povinné pro autocomplete) a
   `allowed-tools` (silně doporučené pro bezpečnost).
3. **Tělo** napiš jako instrukce pro Claude — co má udělat krok po kroku.
4. **Otestuj**: spusť `/<jmeno>` a sleduj, jestli Claude dělá, co má.

## Tipy

- **Krátké, fokusované.** Slash command má jeden úkol.
- **Whitelist nástrojů buď specifický.** Pokud příkaz čte git status, povol
  `Bash(git status)`, ne `Bash(git:*)`.
- **Žádný `Bash(:*)`** — povolil bys vše.
- **Slash command může volat skilly** (`Skill(<jmeno>)`) nebo subagenty
  (`Agent(...)`) — viz `/zavrit-sezeni` výše.
- **Pojmenuj v jazyce, kterým mluvíš.** `/stav` je rychleji napsaný než
  `/status`. `/zavrit-sezeni` je explicitní česky.

## Lokace

1. `~/.claude/commands/` (globální)
2. `<projekt>/.claude/commands/` (projektové, sdílené přes git)
3. Plugin commands (v tomto repu nepoužity)

Pokud existuje stejnojmenný globální i projektový command, projektový vyhrává.

## Užitečné odkazy

- [Slash commands v dokumentaci Claude Code](https://docs.claude.com/en/docs/claude-code/slash-commands)
