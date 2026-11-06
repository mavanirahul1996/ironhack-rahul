#!/usr/bin/env bash
# Smoke-test the Loki lab (run after `docker compose up -d`).
set -u
cd "$(dirname "$0")"
LOKI=http://localhost:3100; PROM=http://localhost:9091
pass=0; fail=0
check() { # retries for up to ~60s: pipelines take a while on a cold start
  for _ in $(seq 1 15); do
    if eval "$2" >/dev/null 2>&1; then echo "  ok   $1"; pass=$((pass+1)); return; fi; sleep 4
  done
  echo "  FAIL $1"; fail=$((fail+1))
}
lq() { curl -sfG "$LOKI/loki/api/v1/query" --data-urlencode "query=$1" | jq -e "$2"; }
NOW=$(date +%s)

echo "waiting for Loki + data (up to 120s)..."
for i in $(seq 1 40); do
  curl -sf $LOKI/ready >/dev/null && lq 'count_over_time({service_name="payments"}[5m])' '.data.result|length>0' >/dev/null 2>&1 && break; sleep 3
done

check "Loki ready"                               "curl -sf $LOKI/ready"
check "Alloy -> Loki: shop (JSON) arrives"       "lq 'count_over_time({service_name=\"shop\"}[5m])' '.data.result|length>0'"
check "Alloy -> Loki: payments (logfmt) arrives" "lq 'count_over_time({service_name=\"payments\"}[5m])' '.data.result|length>0'"
check "LogQL: | json | level filter"            "lq 'count_over_time({service_name=\"shop\"} | json | level=\"error\" [5m])' '.data.result|length>0'"
check "LogQL: | logfmt | filter"                "lq 'count_over_time({service_name=\"payments\"} | logfmt | level=\"error\" [5m])' '.data.result|length>0'"
check "LogQL: unwrap + quantile_over_time"      "lq 'quantile_over_time(0.95, {service_name=\"shop\"} | json | unwrap latency_ms [2m]) by (path)' '.data.result|length>0'"
check "detected_level auto structured metadata" "curl -sfG $LOKI/loki/api/v1/query_range --data-urlencode 'query={service_name=\"payments\"}' --data-urlencode limit=1 | jq -e '.data.result[0].stream.detected_level'"
check "detected_fields API"                     "curl -sfG $LOKI/loki/api/v1/detected_fields --data-urlencode 'query={service_name=\"shop\"}' | jq -e '.fields|length>0'"
check "volume API"                              "curl -sfG $LOKI/loki/api/v1/index/volume --data-urlencode 'query={service_name=~\".+\"}' --data-urlencode start=\$((\$(date +%s)-600)) --data-urlencode end=\$(date +%s) | jq -e '.data.result|length>0'"
check "patterns API (pattern ingester)"         "curl -sfG $LOKI/loki/api/v1/patterns --data-urlencode 'query={service_name=\"payments\"}' --data-urlencode start=\$((\$(date +%s)-600)) --data-urlencode end=\$(date +%s) | jq -e '.data|length>0'"
check "schema is tsdb/v13"                      "curl -sf $LOKI/config | grep -q 'schema: v13'"
check "retention_period = 72h"                  "curl -sf $LOKI/config | grep -q 'retention_period: 3d'"
check "ruler: rules loaded"                     "curl -sf $LOKI/loki/api/v1/rules | grep -q ShopHighErrorRate"
check "ruler -> Prometheus recording rule"      "curl -sfG $PROM/api/v1/query --data-urlencode 'query=shop:errors:rate1m' | jq -e '.data.result|length>0'"
check "too-old sample rejected (400)"           "[ \"\$(curl -s -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' $LOKI/loki/api/v1/push -d '{\"streams\":[{\"stream\":{\"service_name\":\"old\"},\"values\":[[\"1600000000000000000\",\"ancient\"]]}]}')\" = 400 ]"
check "logcli works"                            "docker compose run --rm -T logcli query '{service_name=\"shop\"}' --limit 1 --since 5m --quiet | grep -q ."

# structured metadata via the push API
TS=$(python3 -c 'import time;print(int(time.time()*1e9))')
curl -sf -H 'Content-Type: application/json' $LOKI/loki/api/v1/push -d '{"streams":[{"stream":{"service_name":"lab-test"},"values":[["'$TS'","hello",{"trace_id":"abc123"}]]}]}'
sleep 2
check "push API + structured metadata query"    "lq 'count_over_time({service_name=\"lab-test\"} | trace_id=\"abc123\" [5m])' '.data.result|length>0'"

# OTLP through Alloy -> Loki /otlp
curl -sf -o /dev/null -H 'Content-Type: application/json' localhost:4318/v1/logs -d '{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"otel-test"}}]},"scopeLogs":[{"logRecords":[{"timeUnixNano":"'$TS'","severityText":"WARN","body":{"stringValue":"via otlp"}}]}]}]}'
sleep 3
check "OTLP -> Alloy -> Loki"                   "lq 'count_over_time({service_name=\"otel-test\"}[5m])' '.data.result|length>0'"

echo; echo "passed=$pass failed=$fail"; [ "$fail" -eq 0 ]
