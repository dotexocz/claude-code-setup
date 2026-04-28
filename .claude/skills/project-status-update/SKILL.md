---
name: project-status-update
description: Použij na konci každé pracovní session nebo když uživatel řekne "update CLAUDE.md", "zapiš stav", "ukonči session". Aktualizuje sekci "## Current Status" v projektovém CLAUDE.md.
---

# Aktualizace stavu projektu

## Kdy tento skill použít

- Uživatel říká "ukonči session", "zapiš stav", "update CLAUDE.md"
- Dokončila se logická etapa (commit, merge, deploy)
- Před delší pauzou v práci, aby další session mohla navázat
- Při přechodu na jiný projekt — zaznamenat, kde jsme skončili

## Co skill dělá

Najde a aktualizuje v souboru `CLAUDE.md` (v kořeni projektu) sekci
`## Current Status`. Pokud sekce neexistuje, vytvoří ji.

Sekce má tři pevné podsekce:

```markdown
## Current Status

**Last done:** Co se dokončilo v této session — stručně, 1–3 věty.

**Next:** Co je nejbližší další krok — jako TODO pro další session.

**Known issues:** Co je rozbité, neúplné nebo blokované — vč. krátkého popisu.
```

## Postup

### 1. Načti aktuální CLAUDE.md

```
Read CLAUDE.md
```

Pokud neexistuje, vytvoř nový s celou strukturou (viz globální `~/.claude/CLAUDE.md`
pro vzor).

### 2. Zjisti, co se v session reálně udělalo

- `git log --oneline -20 --since="6 hours ago"` — co se commitlo
- `git status` — co je rozpracováno (uncommitted)
- `git diff --stat` — rozsah změn

### 3. Sestav nový obsah sekce

**Last done:**
- Vyber 1–3 nejvýznamnější věci ze session.
- Pokud možno, odkaz na konkrétní commit hash nebo soubor.
- Špatně: "udělali jsme spoustu věcí"
- Dobře: "Hotová mobilní optimalizace navigace (commit a3f9e21) + opravený výpočet DPH na položku"

**Next:**
- Ne víc než 3 položky.
- Konkrétní, akční, dohledatelné — formát "udělej X v souboru Y".
- Špatně: "pokračovat ve vývoji"
- Dobře: "Napojit formulář v `js/main.js` na Formspree — endpoint zatím chybí v .env"

**Known issues:**
- Pokud nic, napiš jen `žádné`.
- Pokud něco, popiš stručně + odkaz na soubor/řádek/issue.
- Špatně: "něco s autentizací"
- Dobře: "Přihlášení selže pro emaily s diakritikou (`auth/login.ts:42`, validace e-mailu nepřijímá unicode)"

### 4. Edit, ne přepis

Použij **Edit** tool s `old_string` a `new_string`, ne **Write**, abys neztratil
zbytek `CLAUDE.md`.

### 5. Datum a čas

Před sekci `## Current Status` přidej `_Aktualizováno: 2026-04-28 14:32_`
(použij aktuální datum a čas).

## Příklad výstupu

```markdown
_Aktualizováno: 2026-04-28 14:32_

## Current Status

**Last done:** Vytvořena ukázková Claude Code konfigurace (settings, skills,
subagenti, MCP). 3 vlastní skilly + 2 subagenti hotové (commit `f8a23b1`).

**Next:**
- Napsat slash commands (`/stav`, `/zavrit-sezeni`)
- Napsat hlavní README v češtině
- Push na GitHub jako nový repo `claude-code-setup`

**Known issues:** žádné
```

## Co skill **nedělá**

- Nemění jiné sekce CLAUDE.md (pravidla, konvence, architektura).
- Necommituje změny — to je samostatný krok (viz skill `czech-commit-message`).
- Nesnaží se vyplňovat věci, které neví — pokud chybí informace, **zeptá se**
  uživatele.
