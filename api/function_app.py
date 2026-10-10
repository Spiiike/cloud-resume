import json
import logging
import os

import azure.functions as func
from azure.core.exceptions import ResourceNotFoundError
from azure.data.tables import TableServiceClient, UpdateMode

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

PARTITION_KEY = "visitors"
ROW_KEY = "site"


def next_count(entity: dict) -> int:
    """The increment rule. Pure, so it needs no mocks to test."""
    return int(entity.get("count", 0)) + 1


def bump(client) -> int:
    """Read, increment, persist. Takes a client so tests can pass a fake."""
    try:
        entity = client.get_entity(PARTITION_KEY, ROW_KEY)
    except ResourceNotFoundError:
        entity = {"PartitionKey": PARTITION_KEY, "RowKey": ROW_KEY, "count": 0}

    entity["count"] = next_count(entity)
    client.upsert_entity(entity, mode=UpdateMode.REPLACE)
    return entity["count"]


def _table_client():
    connection = os.environ["COSMOS_CONNECTION"]
    table_name = os.environ.get("TABLE_NAME", "counter")
    return TableServiceClient.from_connection_string(connection).get_table_client(table_name)


@app.route(route="counter", methods=["GET", "POST"])
def counter(req: func.HttpRequest) -> func.HttpResponse:
    try:
        count = bump(_table_client())
    except Exception:
        logging.exception("failed to update visitor count")
        return func.HttpResponse(
            json.dumps({"error": "counter unavailable"}),
            status_code=503,
            mimetype="application/json",
        )

    return func.HttpResponse(
        json.dumps({"count": count}),
        mimetype="application/json",
        headers={"Cache-Control": "no-store"},
    )