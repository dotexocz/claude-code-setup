# 4. Subagenti (`.claude/agents/`)

## Co je subagent

**Subagent** je samostatný "Claude" se svým vlastním systémovým promptem,
vlastním whitelistem nástrojů a vlastním kontextem (žádná historie hlavní
session). Hlavní agent ho zavolá přes tool `Agent(...)` a dostane zpět
**jednu textovou zprávu** s výsledkem.

Klíčový rozdíl proti skillu:

| Vlastnost           | Skill                        | Subagent                            |
|---------------------|------------------------------|-------------------------------------|
| Běží v…             | hlavní session               | nové izolované session              |
| Má svůj kontext     | ne, sdílí s hlavní session   | ano                                 |
| Whitelist tools     | ne (smí všechno)             | ano (`tools:` v frontmatter)        |
| Vrátí               | dál pokračuje hlavní session | jeden závěrečný report              |
| Kdy použít          | Návod / pravidlo / šablona   | Nezávislý úkol s vlastním kontextem |

## Anatomie subagenta

Jeden `.md` soubor v `.claude/agents/<jmeno>.md`:

```yaml
---
name: <kebab-case-jmeno>
description: <Kdy hlavní agent má tento subagent zavolat>
tools: Read, Grep, Glob, Bash    # whitelist
---

# Systémový prompt

Markdown text, který subagent dostane jako svůj systémový prompt. Říká mu,
jaký má cíl, jaký má dodržet styl, co nemá dělat.
```

## Subagenti v tomto repu

### 1. `czech-code-reviewer`

**Whitelist:** `Read, Grep, Glob, Bash`

**Kdy ho volat:** Po dokončení dávky změn, před commitem nebo PR. Hlavní
agent si k dispozici nechá svůj kontext, subagent dostane jen ten kus práce
k review.

**Co dělá:**
- Spustí `git status` a `git diff` v izolaci.
- Pro každý změněný soubor přečte celý kontext (ne jen diff).
- Vrátí strukturovaný report v češtině:
  - **Co je v pořádku** (zelená)
  - **Musí se opravit** (červená — funkční chyby, bezpečnost)
  - **Doporučení ke zvážení** (žlutá — max 3–5 položek)

**Proč subagent, ne skill:** Review zahltí kontext (čte se hodně souborů).
Subagent celou tu práci udělá v izolaci a zpátky pošle jen report — hlavní
session zůstane čistá.

### 2. `docs-writer-cs`

**Whitelist:** `Read, Glob, Grep, Write, Edit, Bash`

**Kdy ho volat:** *Napiš README*, *udělej dokumentaci*, *vysvětli, jak to
spustit*.

**Co dělá:**
- Prozkoumá projekt (`ls`, `package.json`, `requirements.txt`, …).
- Sestaví standardní strukturu README (Co umí / Stack / Instalace / Spuštění
  / Struktura / Proměnné / Známé problémy).
- Píše krátké věty, aktivní rod, code blocky pro příkazy.
- Pokud README už existuje, neničí ho — jen doplňuje a opravuje zastaralé
  části přes `Edit`.

**Proč subagent:** Dokumentace vzniká přečtením spousty souborů projektu —
to by hlavní session zaplavilo. Subagent vrátí hotový text README a hlavní
agent ho jen ukáže uživateli ke schválení.

## Jak Claude subagenta zavolá

V hlavní session:

```
Agent({
  description: "Code review aktuální dávky",
  subagent_type: "czech-code-reviewer",
  prompt: "Review změn na branch <jmeno>. Soustřeď se na auth modul.
           Kontext: před týdnem se objevila chyba ..."
})
```

Subagent dostane:
- Svůj systémový prompt z `.claude/agents/czech-code-reviewer.md`
- Prompt z `Agent(...)` volání
- **Žádný** zbytek hlavní session

Vrátí jednu textovou zprávu — to je výstup.

## Whitelist nástrojů

V `tools:` frontmatter určuješ, co subagent **smí**. Pokud parametr vynecháš,
zdědí všechny nástroje hlavní session, což většinou nechceš — review agent
nemá důvod psát nebo mazat soubory.

Možné hodnoty:

```yaml
tools: Read, Grep, Glob, Bash             # jen čtení a hledání
tools: Read, Edit, Write, Bash            # může i upravovat
tools: *                                  # všechno (jako hlavní session)
```

## Kdy použít subagenta a kdy ne

| Použij subagenta když…                                       | Použij skill když…                          |
|--------------------------------------------------------------|---------------------------------------------|
| Úkol vyžaduje hodně čtení, kterým nechceš zaplavit kontext   | Potřebuješ jen šablonu/pravidlo             |
| Úkol je nezávislý a vrací jeden report                       | Akce běží v dialogu s uživatelem            |
| Chceš omezit nástroje (whitelist)                            | Pravidlo je o "jak postupovat", ne "co"     |
| Můžeš ho pustit paralelně s hlavním vláknem                  | Každý krok potřebuje schválení uživatele    |

## Lokace

Stejně jako skilly, subagenti se hledají na třech místech:

1. `~/.claude/agents/`
2. `<projekt>/.claude/agents/`
3. Plugin agenti (v tomto repu nepoužity)
