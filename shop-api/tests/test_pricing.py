import pytest

from shop.pricing import apply_discount, order_total


def test_apply_discount():
    assert apply_discount(100.0, 10) == 90.0


def test_apply_discount_rejects_bad_percent():
    with pytest.raises(ValueError):
        apply_discount(100.0, 150)


def test_order_total():
    items = [{"price": 10.0, "qty": 2}, {"price": 5.5, "qty": 1}]
    assert order_total(items) == 25.5