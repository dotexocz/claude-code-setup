---
description: Zobraz aktuální stav projektu — nedávné commity, rozpracované změny, sekci Current Status z CLAUDE.md.
allowed-tools: Bash(git status), Bash(git log:*), Bash(git diff --stat:*), Bash(git branch --show-current), Read, Glob
---

Zobraz uživateli **stručný přehled, kde jsme v projektu**.

Postup:

1. Zjisti aktuální větev:
   ```
   git branch --show-current
   ```

2. Zjisti, jestli jsou rozpracované změny:
   ```
   git status --short
   ```

3. Posledních 5 commitů:
   ```
   git log --oneline -5
   ```

4. Pokud existuje `CLAUDE.md`, přečti z něj sekci `## Current Status` (jen tu sekci,
   ne celý soubor).

5. Sestav výstup v této struktuře (česky):

```
## Stav projektu

**Větev:** <název>
**Rozpracováno:** <X souborů upravených, Y untracked> | nebo "čistý strom"

**Posledních 5 commitů:**
- <hash> <message>
- ...

**Z CLAUDE.md (Current Status):**
<obsah sekce, pokud existuje; jinak "v projektu chybí sekce Current Status — doporučuji ji založit">
```

Pokud `CLAUDE.md` neexistuje vůbec, **navrhni** uživateli, ať si ho založí
(reference na globální `~/.claude/CLAUDE.md` jako vzor). Neukládej ho automaticky.

Žádné další komentáře, žádný úvod, žádný závěr — jen ten přehled.
