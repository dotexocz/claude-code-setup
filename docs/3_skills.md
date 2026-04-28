# 3. Skilly (`.claude/skills/`)

## Co je skill

**Skill** je modulární kus znalosti — soubor instrukcí, který se Claude
**sám** rozhodne načíst, když narazí na situaci, ve které se hodí. Není
to slash command (ten musíš zavolat ručně) ani subagent (ten běží v izolované
session). Skill je text, který se přiloží do hlavní session jako další
kontext.

Modelu se na začátku sezení ukáže jen `name` a `description` skillu — tělo
se načte teprve když se model rozhodne ho použít. Proto je `description`
**nejdůležitější** část souboru: musí jasně popisovat, **kdy** skill použít.

## Anatomie skillu

```
.claude/skills/<jmeno-skillu>/
└── SKILL.md          ← povinný soubor
```

`SKILL.md` má YAML frontmatter:

```yaml
---
name: <kebab-case-jmeno>
description: <Kdy a proč skill použít. Buď specifický!>
---

# Tělo skillu

Markdown obsah, který Claude dostane do kontextu, když skill aktivuje.
```

## Skilly v tomto repu

### 1. `czech-commit-message`

**Kdy se aktivuje:** Když uživatel řekne *commitni to*, *udělej commit*, *napiš
commit message* nebo ukončuje session.

**Co dělá:**
- Generuje commit zprávu ve formátu `typ: krátký popis česky`.
- Dodržuje Conventional Commits (`feat`, `fix`, `docs`, `style`, `refactor`,
  `test`, `chore`).
- Před commitem zkontroluje, že nejsou ve staged změnách citlivé soubory
  (`.env`, `*.key`, …).
- Zakazuje `--no-verify`.

**Proč:** Globální `~/.claude/CLAUDE.md` definuje konkrétní commit konvenci.
Bez explicitního skillu se model občas vrací k anglickým messages nebo
zapomíná na typ. Skill to znormalizuje.

### 2. `safe-delete-check`

**Kdy se aktivuje:** Před každým mazáním souboru, adresáře, větve, databázových
záznamů. Triggery: `rm`, `git branch -D`, `DROP TABLE`, `git reset --hard`,
…

**Co dělá:**
- Vypíše seznam, **co konkrétně** se smaže (kolik souborů, jaká velikost).
- Hledá nebezpečné signály (kořenové cesty, `.git/`, `~/.ssh/`, wildcardy).
- Nabízí reverzibilní alternativy (`mv` do `~/.Trash`, `git stash`,
  `RENAME TO _archive`).
- Po smazání ověří výsledek a vrátí přehled.

**Proč:** Nejhorší kategorie chyb je nevratná destrukce dat. Skill funguje
jako pojistka, která doplňuje (ne nahrazuje) `deny` pravidla v `settings.json`.

### 3. `project-status-update`

**Kdy se aktivuje:** Konec session, *zapiš stav*, *update CLAUDE.md*.

**Co dělá:**
- Najde a aktualizuje sekci `## Current Status` v `CLAUDE.md`.
- Sekce má tři podsekce: **Last done**, **Next**, **Known issues**.
- Pokud sekce neexistuje, založí ji.
- Použije `Edit` (ne `Write`), aby nepřepsal zbytek souboru.

**Proč:** Globální workflow uživatele má povinný krok "na konci session
update sekce Current Status". Skill to mechanizuje — místo aby uživatel
musel pamatovat, model to dělá automaticky.

## Jak Claude vybírá skilly

1. Při startu sezení dostane seznam *všech* dostupných skillů — jen `name`
   a `description`.
2. Když uživatel pošle zprávu, model si zprávou prochází a hledá, jestli
   popis nějakého skillu odpovídá situaci.
3. Pokud ano, zavolá `Skill(<jmeno>)` a dostane plný obsah `SKILL.md` jako
   další kontext.

**Důsledek:** Pokud `description` napíšeš mlhavě (*"Pomůže s commity"*),
model skill nevybere ve správný moment. Buď konkrétní:

- ❌ *Pomůže s commity*
- ✅ *Použij vždy, když uživatel žádá o vytvoření git commitu nebo se ptá,
   jak pojmenovat commit. Vygeneruje Conventional Commit zprávu — typ
   anglicky, krátký popis česky.*

## Lokace a hierarchie

Skilly se hledají na třech místech:

1. `~/.claude/skills/` (globální, dostupné ve všech projektech)
2. `<projekt>/.claude/skills/` (projektové, sdílené přes git)
3. Plugin / marketplace skilly (v tomto repu **nepoužity**)

Stejné jméno → projekt přebije globální.

## Jak přidat další skill

```bash
mkdir -p .claude/skills/muj-novy-skill
# vytvoř SKILL.md s frontmatter (name, description) + tělem
```

Po restartu Claude Code je skill dostupný.

## Tipy z praxe

- **Krátké skilly fungují líp.** 100–300 řádků markdownu. Když narůstá,
  rozděl ho na víc skillů.
- **`description` formuluj v perspektivě modelu**, ne uživatele. Říkej, *kdy*
  ho zavolat, ne *co dělá*.
- **Skill nesmí "nutit" akci** — má radit a být reverzibilní. Pokud má
  kontrolní povahu (jako `safe-delete-check`), to je v pořádku.
- **Testuj** — uvádějteruckou frázi, kterou očekáváš že skill spustí, a
  ověř, že ji Claude opravdu spustí.
