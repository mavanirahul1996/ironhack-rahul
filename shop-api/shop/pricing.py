def apply_discount(price, percent):
    if percent < 0 or percent > 100:
        raise ValueError("percent must be between 0 and 100")
    return round(price * (1 - percent / 100), 2)


def order_total(items):
    return round(sum(i["price"] * i["qty"] for i in items), 2)