---
description: Ukonči pracovní session — aktualizuj Current Status, navrhni commit message, připomeň push.
allowed-tools: Bash(git status), Bash(git log:*), Bash(git diff:*), Bash(git diff --staged:*), Bash(git branch --show-current), Read, Edit, Skill
---

Pomoz uživateli **správně ukončit pracovní session**.

Postup:

### 1. Zjisti, co se za session změnilo

```
git status --short
git diff --stat
git log --oneline --since="6 hours ago"
```

### 2. Pokud existuje `CLAUDE.md`, aktualizuj sekci `## Current Status`

Použij skill **`project-status-update`** přes tool `Skill`:

```
Skill(project-status-update)
```

Skill se postará o správný formát (Last done / Next / Known issues +
datum aktualizace).

### 3. Pokud jsou neuložené změny, navrhni commit

Použij skill **`czech-commit-message`**:

```
Skill(czech-commit-message)
```

Skill vygeneruje vhodnou commit zprávu ve formátu `typ: krátký popis česky`.

**Sám commit nedělej.** Jen ukaž návrh a počkej na potvrzení uživatele.

### 4. Připomeň push

Pokud má uživatel commity, které ještě nejsou v remote, řekni:
```
Branch <název> má X lokálních commitů, které ještě nejsou na origin.
Spusť: git push
```

(Sám `git push` **neprováděj** — to ať udělá uživatel sám, podle globálního
pravidla "nikdy nepushuj na main bez ptaní".)

### 5. Závěrečný souhrn

Vypiš česky:

```
## Konec session

Hotovo:
- <bullet list co se reálně udělalo, max 3 položky>

Připraveno k commitu:
- <pokud něco>

Nepushnuto:
- <pokud něco>

Příště:
- <z Current Status: Next, max 3 položky>
```

Pokud session **nepřinesla žádné změny** (žádné commity, žádné neuložené úpravy),
prostě řekni "Žádné změny v session, stav projektu beze změny" a skonči.
