# Grafana Loki workshop (lab, 2026)

Hands-on lab for **Grafana Loki 3.7**, collecting with **Grafana Alloy 1.21**
(Promtail is end-of-life since 2026-03-02, so it is not used here).

Requires Docker with Compose v2, `curl`, `jq` and `python3`.

Single-binary Loki on filesystem storage, **Alloy as the collector**
(Promtail is end-of-life since 2026-03-02 — it is deliberately not used here),
Prometheus for ruler output, Grafana to explore.

```
 shop (JSON) ─┐                        ┌─► Grafana    :3030
 payments     ├─ docker.sock ─► Alloy ─┤
 (logfmt)    ─┘                  │     └─► Prometheus :9091 ◄── Loki ruler (recording rules)
 OTLP :4318 ──────────────────► ─┴──────► Loki :3100
```

> Not production: `auth_enabled: false`, one replica, local filesystem.
> Stop the Alloy lab before starting this one — they share the same ports.

## Run

```sh
docker compose up -d
./test.sh                       # 18 checks → passed=18 failed=0
alias logcli='docker compose run --rm -T logcli'   # optional
```

Grafana: <http://localhost:3030> → Explore → *Loki* (anonymous admin).

## Exercises

### 1. Streams and selectors
```logql
{service_name="shop"}
{service_name=~"shop|payments"} |= "error"
```
`curl localhost:3100/loki/api/v1/labels` — which labels exist? Only `service_name`
(+ `detected_level` as *structured metadata*). Alloy did **not** index `level`.

### 2. Parse at query time
```logql
{service_name="shop"}     | json   | level="error" | latency_ms > 500
{service_name="payments"} | logfmt | level="error"
{service_name="payments"} | logfmt | line_format "{{.order}}: {{.msg}}"
```

### 3. Metric queries
```logql
sum by (level) (count_over_time({service_name="shop"} | json [1m]))
quantile_over_time(0.95, {service_name="shop"} | json | unwrap latency_ms [2m]) by (path)
topk(3, sum by (msg) (count_over_time({service_name="payments"} | logfmt | level="error" [5m])))
```

### 4. Structured metadata (`trace_id`) vs labels
`trace_id` is in the JSON body. Filter it *after* the selector:
```logql
{service_name="shop"} | json | trace_id="<paste one>"
```
Push a line with real structured metadata and query it with no parser:
```sh
TS=$(python3 -c 'import time;print(int(time.time()*1e9))')
curl -H 'Content-Type: application/json' localhost:3100/loki/api/v1/push \
  -d '{"streams":[{"stream":{"service_name":"demo"},"values":[["'$TS'","hello",{"trace_id":"abc123"}]]}]}'
```
```logql
{service_name="demo"} | trace_id="abc123"
```

### 5. Cardinality, felt
```sh
curl -s localhost:3100/metrics | grep ^loki_ingester_memory_streams   # note the number
for i in $(seq 1 100); do
  curl -s -H 'Content-Type: application/json' localhost:3100/loki/api/v1/push \
   -d '{"streams":[{"stream":{"service_name":"bad","user":"u'$i'"},"values":[["'$(python3 -c 'import time;print(int(time.time()*1e9))')'","x"]]}]}'
done
curl -s localhost:3100/metrics | grep ^loki_ingester_memory_streams   # +100 streams
```
One label with 100 values = 100 streams = 100 tiny chunks. This is what to avoid.

### 6. Logs Drilldown APIs
```sh
# volume per service
curl -sG localhost:3100/loki/api/v1/index/volume --data-urlencode 'query={service_name=~".+"}' \
  --data-urlencode start=$(($(date +%s)-600)) --data-urlencode end=$(date +%s) | jq
# automatically detected patterns
curl -sG localhost:3100/loki/api/v1/patterns --data-urlencode 'query={service_name="payments"}' \
  --data-urlencode start=$(($(date +%s)-600)) --data-urlencode end=$(date +%s) | jq '.data[].pattern'
# detected fields
curl -sG localhost:3100/loki/api/v1/detected_fields --data-urlencode 'query={service_name="shop"}' | jq
```

### 7. logcli
```sh
logcli query '{service_name="payments"} | logfmt | level="error"' --since 10m --limit 5
logcli series '{}' --since 10m
logcli labels --since 10m
```

### 8. Ruler: logs → metrics → alerts
`rules/rules.yaml` is evaluated by Loki every 10s and *remote-written* to Prometheus:
```sh
curl -sG localhost:9091/api/v1/query --data-urlencode 'query=shop:errors:rate1m' | jq
curl -s localhost:3100/loki/api/v1/rules
```
Change the threshold, `docker compose restart loki`.

### 9. Limits and retention
```sh
# older than reject_old_samples_max_age (7d)? → HTTP 400
curl -i -H 'Content-Type: application/json' localhost:3100/loki/api/v1/push \
  -d '{"streams":[{"stream":{"service_name":"old"},"values":[["1600000000000000000","ancient"]]}]}'
curl -s localhost:3100/config | grep -E 'retention_period|reject_old|max_global_streams'
```
`retention_period: 72h` is enforced by the **compactor** (`retention_enabled: true`).

### 10. OTLP
```sh
TS=$(python3 -c 'import time;print(int(time.time()*1e9))')
curl -H 'Content-Type: application/json' localhost:4318/v1/logs -d '{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"my-app"}}]},"scopeLogs":[{"logRecords":[{"timeUnixNano":"'$TS'","severityText":"ERROR","body":{"stringValue":"boom"},"attributes":[{"key":"order.id","value":{"stringValue":"o-1"}}]}]}]}]}'
```
`{service_name="my-app"}` → check the stream labels and structured metadata (`order_id`).

## Clean up
```sh
docker compose down -v
```
