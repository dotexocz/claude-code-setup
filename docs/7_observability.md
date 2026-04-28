# 7. Observability (telemetrie)

## Proč

Observability ti odpovídá na otázky **"co Claude Code v praxi dělá?"**:

- Kolik tokenů jsem spotřeboval za týden?
- Kolikrát selhal který tool?
- Kolik latence má každý API request?
- Které skilly se reálně aktivují, a které nikdy?

Bez metrik se rozhoduješ podle pocitu. S metrikami víš, kam zaměřit
optimalizaci (např. že subagent na Haiku je pětkrát rychlejší a stojí desetinu
toho, co Opus).

## Co Claude Code nabízí

Claude Code podporuje **OpenTelemetry** — otevřený standard pro telemetrii
od CNCF (Cloud Native Computing Foundation). To znamená, že metriky a logy
můžeš posílat do libovolného OTel-kompatibilního backendu:

- **Console** (jen výpis do terminálu — pro učení a debug)
- **Honeycomb** / **Datadog** / **New Relic** / **Grafana Cloud**
- **Lokální OTel kolektor** (Jaeger, Prometheus, Grafana on-prem)

## Vrstvy

### 1. Lokální audit log (žádný OTel) – už je v tomto repu

`.claude/edits.log` plněný PostToolUse hookem (viz [`docs/6_hooks.md`](6_hooks.md)).
Nejjednodušší forma observability — žádné nástroje navíc.

### 2. Console exporter (učení)

Nejjednodušší způsob, jak vidět **každou** metriku Claude Code, je vypnout
exporter `console`. Metriky se sypou do stderr, takže je vidíš přímo v
terminálu.

**Aktivace** (zapni v shellu před spuštěním Claude Code):

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=console
export OTEL_LOGS_EXPORTER=console
export OTEL_METRIC_EXPORT_INTERVAL=60000   # ms — jak často flushovat
claude
```

Nebo vlož do `.envrc` (direnv) nebo `~/.zshrc`, ať platí trvale.

**Co uvidíš:** Každou minutu se v terminálu objeví výpis metrik typu:

```
{
  "name": "claude_code.token.usage",
  "type": "counter",
  "value": 12834,
  "attributes": {
    "model": "claude-opus-4-7",
    "type": "input"
  }
}
```

### 3. OTLP exporter (produkce)

Pro reálnou observability posíláš metriky **OTLP protokolem** do kolektoru:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

A spusť OTel kolektor lokálně (Docker):

```bash
docker run -p 4317:4317 -p 4318:4318 otel/opentelemetry-collector
```

Z kolektoru pak metriky proudí do Prometheus / Grafana / Honeycomb / atd.

## Klíčové metriky, které stojí za to sledovat

| Metrika                              | Co říká                                       |
|--------------------------------------|-----------------------------------------------|
| `claude_code.session.count`          | Kolik sezení proběhlo                         |
| `claude_code.token.usage`            | Vstup/výstup/cache tokeny — náklady           |
| `claude_code.tool.usage`             | Které tooly se používají nejvíc               |
| `claude_code.api.request.duration`   | Latence API volání na Claude                  |
| `claude_code.api.error`              | Kolik requestů selhalo a proč                  |

## Logy

Kromě metrik existuje i log stream — jednotlivé eventy (user prompt, tool call,
tool response, model response). Tyto logy mohou obsahovat **citlivé údaje**
(cesty k souborům, obsah promptů). Při zapnutí pamatuj na:

- **Sanitizaci.** Nelogovat plné prompty, jen jejich hash a délku.
- **Lokální storage.** Před cloud kolektorem si rozmysli, co tam pouštíš.
- **Retention.** Nastavit kratší retention než výchozí.

## Proč tohle není zapnuté v `settings.json`

V `.claude/settings.json` v tomto repu schválně **nezapínám** OpenTelemetry
defaultně:

1. Console exporter zaplaví terminál — uživatel by si to pak ručně zase
   vypínal.
2. OTLP exporter vyžaduje běžící kolektor, který tady nikdo nemá.
3. Telemetrie posílá metadata (jméno modelu, počet tokenů) — to je v pohodě,
   ale ať se uživatel sám rozhodne, jestli chce.

Místo toho je tu **návod, jak si to zapnout**, když je k tomu příležitost.

## Co prakticky doporučuji

**Pro učení a debug** (lokálně, bez backendu):
- ✅ Lokální audit log z hooku (`.claude/edits.log`) — už je tady.
- ✅ Občas zapnout `console` exporter pro pár minut, podívat se na čísla.

**Pro tým** (víc lidí, sdílené projekty):
- ✅ Lokální OTel kolektor + Grafana, sdílený dashboard tokenů a latence.

**Pro nasazení** (např. firma s Claude Code v daily workflow):
- ✅ Centralizovaný backend (Honeycomb / Datadog), retention 30 dní.
- ✅ Alerting na neobvyklé skoky tokenů — někdo dělá něco drahého.

## Užitečné odkazy

- [OpenTelemetry SDK env vars](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/)
- [Claude Code monitoring docs](https://docs.claude.com/en/docs/claude-code/monitoring-usage)
