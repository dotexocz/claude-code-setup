---
name: safe-delete-check
description: Použij před každým mazáním souborů, adresářů, větví, databázových záznamů nebo destruktivních git operacích. Vypíše seznam toho, co bude smazáno, a počká na potvrzení uživatele.
---

# Bezpečná kontrola před mazáním

## Kdy tento skill použít

Vždy, když se chystáš zavolat něco z následujícího:

- `rm`, `rm -r`, `rm -rf`
- `git branch -D`, `git push --delete`
- `git reset --hard`, `git checkout --` (přepíše neuložené změny)
- `DROP TABLE`, `DELETE FROM`, `TRUNCATE` v SQL
- `unlink()`, `fs.rm()`, `shutil.rmtree()` v kódu
- Smazání řádků v Google Sheets, Supabase, Airtable přes API
- `kill -9`, `pkill` na neznámé procesy

## Postup

### 1. NEMAŽ HNED. Vypiš seznam.

Před spuštěním destruktivního příkazu vypiš uživateli, co konkrétně se smaže:

```
Chystám se smazat tyto položky:
- soubor: ~/projekt/test.log (12 KB)
- adresář: ~/projekt/temp/ (47 souborů, 380 MB)
- větev: feature/old-design (lokální i remote)

Pokračovat? (čekám na "ano")
```

### 2. Zkontroluj, co tam je

Než vypíšeš seznam, **přečti si**, co budeš mazat:

- `ls -la <cesta>` — kolik souborů a velikost
- `cat <soubor>` — co je uvnitř, pokud je to malý soubor
- `git status` — jsou tam neuložené změny?
- `git stash list` — nejsou v stash důležité věci?

### 3. Hledej "nebezpečné signály"

**STOP** a požádej o explicitní potvrzení, pokud cesta obsahuje:

- `~/`, `/`, `/Users/`, `/home/` (root cesty)
- `.git/` — adresář verzování
- `.ssh/`, `.gnupg/`, `.aws/` — bezpečnostní klíče
- `node_modules/` — OK smazat, ale ujisti se, že existuje `package.json` na regenerování
- `.env`, `*.key`, `credentials*.json` — citlivé soubory
- Cesta obsahuje `*` nebo `**` — wildcard může smazat víc, než čekáš
- Větev je `main`, `master`, `production`, `develop`

### 4. Nabídni reverzibilní alternativu

Místo nenávratného `rm` zkus:

| Místo                         | Použij                                         |
|-------------------------------|------------------------------------------------|
| `rm -rf folder/`              | `mv folder/ ~/.Trash/folder-$(date +%s)/`     |
| `git reset --hard`            | `git stash` (uloží změny stranou)              |
| `git branch -D feature`       | `git branch -m feature feature-deleted-2026..` |
| `DROP TABLE users`            | `ALTER TABLE users RENAME TO _users_archive`   |

### 5. Po smazání: ověření

Po destruktivní akci zavolej:

- `ls <rodičovský adresář>` — ověř, že se smazalo, co mělo
- `git status` + `git log --oneline -5` — pokud šlo o git operaci
- Připrav uživateli **přehled, co se reálně smazalo** (počet souborů, velikost)

## Speciální případ: databáze

Pro DELETE/DROP/TRUNCATE v databázi:

1. Spusť **nejdřív SELECT** se stejnými WHERE podmínkami a zobraz počet řádků.
2. Pokud je to víc než ~10 řádků, výslovně se zeptej.
3. **Nikdy** nemaž bez `WHERE` (kromě případu, kdy se uživatel cíleně chce
   zbavit celé tabulky a víš, že existuje záloha).
4. Pokud DB podporuje, zabal mazání do transakce a před `COMMIT` se zeptej.

## Co tento skill **nedělá**

- Nemaže nic sám.
- Neobchází bezpečnostní pravidla v `settings.json` deny listu.
- Nepřepisuje uživatelovo "ne pokračuj".
