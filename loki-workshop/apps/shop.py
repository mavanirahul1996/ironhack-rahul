"""JSON logs: web shop."""
import json, random, time, uuid, datetime
PATHS = ["/cart", "/checkout", "/search", "/product/42"]
while True:
    path = random.choice(PATHS)
    level = random.choices(["info", "warn", "error"], weights=[85, 10, 5])[0]
    print(json.dumps({
        "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "level": level, "path": path,
        "status": {"info": 200, "warn": 429, "error": 500}[level],
        "latency_ms": random.randint(3, 900),
        "user": f"u{random.randint(1, 5000)}",
        "trace_id": uuid.uuid4().hex,
        "msg": f"request {path} handled",
    }), flush=True)
    time.sleep(random.uniform(0.1, 0.5))
