# 6. Hooks (`.claude/hooks/`)

## Co je hook

**Hook** je shell příkaz, který Claude Code spustí v určitých momentech
životního cyklu (před/po toolu, na začátku/konci session, …). Hook dostane
JSON na stdin, může v něm cokoli udělat (logování, validace, blokování) a
podle exit kódu může operaci povolit, zablokovat nebo si jen tiše dělat
svoji práci.

Hooks jsou **mechanismus harness**, ne modelu. Claude se nemůže rozhodnout
hook nespustit — když je nakonfigurovaný, prostě se spustí. Proto je to
ideální místo pro audit a vynucování pravidel.

## Hook eventy

| Event              | Kdy se spustí                                              |
|--------------------|------------------------------------------------------------|
| `SessionStart`     | Při startu nové session                                    |
| `UserPromptSubmit` | Když uživatel pošle zprávu                                 |
| `PreToolUse`       | Před každým voláním toolu (může operaci zablokovat)         |
| `PostToolUse`      | Po každém voláním toolu (úspěch i chyba)                    |
| `Stop`             | Když Claude dokončí odpověď                                |
| `SubagentStop`     | Když subagent dokončí                                      |
| `PreCompact`       | Před tím, než harness komprimuje historii                  |

Hook se v `settings.json` mapuje s **matcherem** — regex na jméno toolu nebo
typu události — a seznamem příkazů.

## Hook v tomto repu

V `.claude/settings.json`:

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Edit|Write|MultiEdit|NotebookEdit",
      "hooks": [
        {
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/log-edits.sh"
        }
      ]
    }
  ]
}
```

**Co to dělá:** Po každém úspěšném `Edit`, `Write`, `MultiEdit` nebo
`NotebookEdit` zavolá skript `log-edits.sh`, který do souboru
`.claude/edits.log` zapíše jeden řádek s časem, jménem toolu, cestou
upraveného souboru a session ID.

**Proč:**
1. **Audit trail** — kdykoli si můžeš pustit `tail .claude/edits.log` a
   vidět, co Claude v projektu měnil.
2. **Debugging** — když něco nefunguje, snadno dohledáš, co Claude upravil
   těsně před chybou.
3. **Bezpečnost** — pokud Claude náhodou upraví něco, co neměl, máš o tom
   záznam.

## Anatomie skriptu `log-edits.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"                                     # JSON ze stdin

tool="$(echo "$input" | jq -r '.tool_name')"
file="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // "n/a"')"
session="$(echo "$input" | jq -r '.session_id')"
timestamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"

log_file="${CLAUDE_PROJECT_DIR}/.claude/edits.log"
mkdir -p "$(dirname "$log_file")"

printf '%s | %-12s | %s | %s\n' "$timestamp" "$tool" "$file" "$session" >> "$log_file"
exit 0
```

Klíčové detaily:

- **`set -euo pipefail`** — když cokoliv selže, skript ukončí. Tím se
  vyhneš tichým chybám.
- **`exit 0`** — vždy povol operaci. Toto je read-only sledování, ne
  policing.
- **Vyhýbáme se rekurzi** — pokud by Claude upravoval samotný `edits.log`,
  hook to detekuje a neloguje (jinak by se logovalo logování).
- **`CLAUDE_PROJECT_DIR`** je env var nastavená Claude Code na kořen projektu.

## JSON na stdin

Pro `PostToolUse` přijde JSON ve tvaru:

```json
{
  "session_id": "abc123",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "old_string": "...",
    "new_string": "..."
  },
  "tool_response": { "success": true },
  "cwd": "/path/to/project"
}
```

Pomocí `jq` extrahuješ, co potřebuješ. Pro NotebookEdit má `tool_input` místo
`file_path` jen `notebook_path` — proto fallback `// .tool_input.notebook_path`.

## Co se dá ještě dělat (inspirace)

### `PreToolUse` zablokování nebezpečných příkazů

```bash
# .claude/hooks/block-curl-piped-bash.sh
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE 'curl.*\|.*(bash|sh|zsh)'; then
  echo "Blokováno: 'curl | bash' je nebezpečný vzor." >&2
  exit 2    # exit code 2 = blokovat operaci
fi
exit 0
```

V settings.json:
```json
"PreToolUse": [{
  "matcher": "Bash",
  "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/block-curl-piped-bash.sh" }]
}]
```

### `SessionStart` zobrazení Current Status

```bash
# .claude/hooks/show-status.sh
if [ -f "$CLAUDE_PROJECT_DIR/CLAUDE.md" ]; then
  echo "=== Current Status ==="
  awk '/^## Current Status/,/^## /' "$CLAUDE_PROJECT_DIR/CLAUDE.md" | head -20
fi
```

Takhle uživatel hned po `claude` vidí, kde skončil minule.

### `Stop` push reminder

Po dokončení každé Claudovy odpovědi zkontroluj, jestli jsou commity bez push,
a uživatele upozorni.

## Exit kódy

| Exit code | Význam                                                            |
|-----------|-------------------------------------------------------------------|
| `0`       | OK, pokračuj                                                       |
| `2`       | Blokovat operaci (jen pro `PreToolUse`); zpráva ze stderr jde Claude |
| jiné       | Chyba (logováno do telemetrie, ale operace se neblokuje)            |

**Pozor:** Pokud se hook zasekne, blokuje to celou session. Vždy nastav
`set -euo pipefail` a vyhni se síťovým voláním v hooku.

## Bezpečnost hooks

Hooks běží **lokálně s tvými právy** — můžou číst, mazat soubory, posílat
síťové požadavky. Než přidáš cizí hook, **přečti si ho**. Stejně jako u
Bash skriptů.

V tomto repu je `log-edits.sh` jednoduchý a transparentní (~30 řádků), takže
jeho audit zabere minutu.
