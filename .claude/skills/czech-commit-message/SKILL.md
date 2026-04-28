---
name: czech-commit-message
description: Použij vždy, když uživatel žádá o vytvoření git commitu nebo se ptá, jak pojmenovat commit. Vygeneruje Conventional Commit zprávu — typ anglicky, krátký popis česky.
---

# Český commit message

## Kdy tento skill použít

- Uživatel řekne "commitni to", "udělej commit", "napiš mi commit message"
- Uživatel ukončuje session a ptá se, jak změny uložit
- Při vytváření PR potřebuješ smysluplné commity

## Pravidla pro commit zprávu

Formát: `<typ>: <krátký popis česky>`

### Povolené typy (anglicky, malými písmeny)

| Typ        | Použití                                                 |
|------------|---------------------------------------------------------|
| `feat`     | Nová funkce, nová obrazovka, nová schopnost             |
| `fix`      | Oprava chyby, regrese                                   |
| `docs`     | Změna dokumentace, README, komentářů                    |
| `style`    | Formátování, mezery, středníky — bez změny chování      |
| `refactor` | Úprava kódu beze změny chování (přejmenování, rozdělení) |
| `test`     | Přidání nebo úprava testů                               |
| `chore`    | Konfigurace, závislosti, build skripty                  |

### Pravidla pro popis

1. **Píše se česky**, malým písmenem na začátku.
2. **Bez tečky** na konci.
3. **Imperativ**: "přidej", "oprav", "uprav" — ne "přidává", "opraveno".
4. **Maximálně 60 znaků** v hlavičce (typ + dvojtečka + popis).
5. Pokud potřebuješ vysvětlit *proč*, přidej prázdný řádek a delší tělo.

### Co dělat před vytvořením commitu

1. Spusť `git status` — zjisti, co je staged a co untracked.
2. Spusť `git diff --staged` — podívej se na obsah změn.
3. Pokud jsou ve změnách citlivé soubory (`.env`, `*.key`, `credentials*.json`),
   **STOP** — upozorni uživatele a počkej na potvrzení.
4. Spusť `git log --oneline -10` — podívej se na styl předchozích commitů.
5. Nikdy nepoužívej `--no-verify` nebo `--no-gpg-sign`, pokud o to uživatel
   výslovně nepožádá.

## Příklady

**Dobré:**
- `feat: přidej přihlašovací formulář`
- `fix: oprav výpočet DPH u zaokrouhlení`
- `refactor: rozděl AuthService na menší třídy`
- `docs: přidej sekci o instalaci do README`
- `chore: aktualizuj Next.js na 15.2`

**Špatné:**
- `update` *(chybí typ a kontext)*
- `feat: Added new login form.` *(anglicky, velké písmeno, tečka)*
- `fix: opraveno` *(neimperativní, žádný kontext)*
- `wip` *(nikdy do hlavní větve)*

## Vícekrokový commit (rozsáhlejší změny)

Pro větší změny použij delší tělo:

```
feat: napoj formulář na Formspree

- přidej FORMSPREE_ENDPOINT do .env.example
- v js/main.js použij endpoint pro POST
- přidej validaci povinných polí před odesláním

Důvod: nahrazuje původní placeholder, formulář teď reálně odesílá zprávy.
```

## Bezpečnostní kontrola

Než zavoláš `git commit`, zkontroluj:
- ✅ `.env` ani `*.key` nejsou ve staged změnách
- ✅ `node_modules/` ani `__pycache__/` nejsou ve staged změnách
- ✅ V kódu nejsou hardcoded API klíče, hesla, tokeny
- ✅ `.gitignore` existuje a obsahuje očekávané položky

Pokud najdeš podezřelý obsah, **ohlaš ho uživateli** a nepokračuj automaticky.
