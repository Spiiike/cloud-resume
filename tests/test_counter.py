from unittest.mock import MagicMock

import pytest
from azure.core.exceptions import ResourceNotFoundError

from function_app import bump, next_count


def test_next_count_starts_at_one():
    assert next_count({}) == 1


def test_next_count_increments():
    assert next_count({"count": 41}) == 42


def test_next_count_coerces_strings():
    """Table storage can hand back a string; the rule must not concatenate."""
    assert next_count({"count": "7"}) == 8


def test_bump_creates_the_entity_when_missing():
    client = MagicMock()
    client.get_entity.side_effect = ResourceNotFoundError("no such entity")

    assert bump(client) == 1

    client.upsert_entity.assert_called_once()
    written = client.upsert_entity.call_args.args[0]
    assert written["count"] == 1
    assert written["PartitionKey"] == "visitors"
    assert written["RowKey"] == "site"


def test_bump_increments_an_existing_entity():
    client = MagicMock()
    client.get_entity.return_value = {
        "PartitionKey": "visitors",
        "RowKey": "site",
        "count": 41,
    }

    assert bump(client) == 42
    assert client.upsert_entity.call_args.args[0]["count"] == 42


def test_bump_propagates_storage_failures():
    """The handler turns this into a 503; bump itself must not swallow it."""
    client = MagicMock()
    client.get_entity.return_value = {"count": 1}
    client.upsert_entity.side_effect = RuntimeError("cosmos down")

    with pytest.raises(RuntimeError):
        bump(client)