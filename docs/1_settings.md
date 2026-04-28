# 1. Settings (`.claude/settings.json`)

## K čemu slouží

Soubor `settings.json` v adresáři `.claude/` říká Claude Code:

- Které **nástroje smí používat bez ptaní** (`permissions.allow`)
- Které **nástroje má vždy zakázané** (`permissions.deny`)
- Jaké **proměnné prostředí** mu předat (`env`)
- Jaké **MCP servery** zapnout (`mcpServers`)
- Další chování (notifikace, voice, hooks, …)

Bez tohoto souboru se Claude na **každý** Bash příkaz, Edit nebo Write zeptá —
to je sice bezpečné, ale brzdí to práci.

## Jak `settings.json` v tomto repu vypadá

Tři hlavní bloky:

### 1. `env` – proměnné prostředí pro Claude Code

```json
"env": {
  "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
}
```

`CLAUDE_CODE_SUBAGENT_MODEL=haiku` znamená, že subagenti se budou spouštět
na rychlejším a levnějším modelu Haiku 4.5, místo aby dědili Opus z hlavní
session. Pro krátké jednorázové úkoly (review, search, lookup) je to
ideální — nepotřebuješ Opus na to, aby ti subagent našel string v repu.

### 2. `permissions.allow` – co Claude smí bez ptaní

Příklad:

```json
"allow": [
  "Bash(git status)",
  "Bash(git diff:*)",
  "Bash(npm run:*)",
  "Read",
  "Edit",
  "Write",
  "Skill",
  "Agent"
]
```

Tvar `Bash(npm run:*)` znamená "libovolný `npm run <něco>`". Hvězdička je
glob — pokud bys napsal jen `Bash(npm run)`, povolil bys přesně ten string,
nic víc.

`Read`, `Edit`, `Write` (bez závorek) povolují tool obecně — Claude smí
číst/upravovat libovolný soubor (kromě toho, co je v `deny`).

### 3. `permissions.deny` – co Claude **nesmí nikdy**

Tahle část je **kritická**. Příklad:

```json
"deny": [
  "Bash(rm -rf /)",
  "Bash(sudo rm -rf:*)",
  "Bash(git push --force:*)",
  "Bash(git commit --no-verify:*)",
  "Read(./.env)",
  "Read(./**/.env)",
  "Read(~/.ssh/**)",
  "Read(./node_modules/**)"
]
```

Co je důležité:

- **Nemazat root** (`rm -rf /`, `~`, `*`) — i když je to absurdní, model může
  udělat překlep a deny lista to zachytí.
- **Neuvolnit citlivé soubory.** `.env` obsahuje API klíče. `~/.ssh/` má
  soukromé klíče. Ani omylem nečíst.
- **Nezhoupnout práci `--no-verify`.** Tím by se obešel pre-commit hook,
  který kontroluje formátování, lintery, test passing.
- **Nepushnout silově.** `git push --force` může přepsat cizí commity na
  remote.
- **Nečíst `node_modules/`.** To je 100k souborů cizího kódu, akorát zaplní
  kontextové okno modelu.

## Hierarchie settings souborů

Claude Code načítá nastavení v tomto pořadí (pozdější přebíjí dřívější):

1. `~/.claude/settings.json` (globální)
2. `<projekt>/.claude/settings.json` (projektový — verzovaný v gitu)
3. `<projekt>/.claude/settings.local.json` (osobní override — **ne** do gitu)

Proto je `settings.local.json` v `.gitignore`. Tam si můžeš přidat své
osobní permise pro experimenty, aniž by to zasáhlo ostatní.

## Jak přidat nové povolení

Když Claude požádá o povolení nějakého příkazu, který chceš trvale povolit,
přidej ho do `allow` v projektovém `settings.json`. Pravidla:

- **Buď specifický.** `Bash(rm:*)` je nebezpečné. `Bash(rm /tmp/*.log)` je OK.
- **Hvězdička jen tam, kde dává smysl.** `Bash(git diff:*)` ano (různé argumenty).
  `Bash(:*)` určitě **ne** (povolíš úplně všechno).
- **Pokud je to citlivé, dej to jen do `settings.local.json`.** Ostatní si
  to musí explicitně povolit sami.

## Co se sem **nedává**

- API klíče a tokeny — patří do `.env`.
- Cesty k osobním souborům, které ostatní nemají.
- Plugin/marketplace konfigurace (`enabledPlugins`, `extraKnownMarketplaces`)
  — toto zadání kurzu zakazuje pluginy, takže tady úplně chybí.
