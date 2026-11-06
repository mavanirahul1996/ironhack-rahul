"""logfmt logs: payments."""
import random, time, datetime
REASONS = ["card declined", "insufficient funds", "gateway timeout", "ok"]
while True:
    r = random.choices(REASONS, weights=[4, 3, 2, 91])[0]
    level = "info" if r == "ok" else random.choice(["warn", "error"])
    ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    print(f'ts={ts} level={level} order=o-{random.randint(1000,9999)} '
          f'amount={random.randint(5,500)} provider={random.choice(["stripe","adyen"])} '
          f'msg="{r}"', flush=True)
    time.sleep(random.uniform(0.3, 1.0))
