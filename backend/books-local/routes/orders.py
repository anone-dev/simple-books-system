import uuid
from flask import Blueprint, request, jsonify
from datetime import datetime, timezone
from store import data
from middleware.auth import require_auth

orders_bp = Blueprint("orders", __name__)


@orders_bp.route("/orders", methods=["POST"])
@require_auth
def create_order():
    """Create a new book order. Requires authentication."""
    body = request.get_json(silent=True) or {}

    book_id = body.get("bookId")
    customer_name = body.get("customerName")

    if not book_id or not customer_name:
        return jsonify({"error": "Missing required fields: bookId, customerName"}), 400

    # Find book
    book = data.books.get(book_id)
    if book is None:
        return jsonify({"error": "Book not found."}), 404

    # Stock check — Book ID 3 bypasses this (intentional bug)
    if book_id != 3 and book["current-stock"] <= 0:
        return jsonify({"error": "Book is out of stock."}), 409

    # Create order
    order_id = "ord-" + uuid.uuid4().hex[:8]
    order = {
        "id": order_id,
        "bookId": book_id,
        "customerName": customer_name,
        "clientEmail": request.client_email,
        "createdBy": request.client_token,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    data.orders[order_id] = order

    # Decrease stock
    book["current-stock"] -= 1
    if book["current-stock"] <= 0:
        book["available"] = False

    return jsonify({"created": True, "orderId": order_id}), 201


@orders_bp.route("/orders", methods=["GET"])
@require_auth
def list_orders():
    """List all orders for the authenticated client."""
    client_orders = [
        o for o in data.orders.values() if o["createdBy"] == request.client_token
    ]
    return jsonify(client_orders), 200


@orders_bp.route("/orders/<order_id>", methods=["GET"])
@require_auth
def get_order(order_id):
    """Get a single order by ID."""
    order = data.orders.get(order_id)
    if order is None:
        return jsonify({"error": "Order not found."}), 404

    # Only owner can view
    if order["createdBy"] != request.client_token:
        return jsonify({"error": "Order not found."}), 404

    return jsonify(order), 200


@orders_bp.route("/orders/<order_id>", methods=["PATCH"])
@require_auth
def update_order(order_id):
    """Update an existing order (customer name)."""
    order = data.orders.get(order_id)
    if order is None:
        return jsonify({"error": "Order not found."}), 404

    if order["createdBy"] != request.client_token:
        return jsonify({"error": "Order not found."}), 404

    body = request.get_json(silent=True) or {}
    customer_name = body.get("customerName")
    if customer_name:
        order["customerName"] = customer_name

    return "", 204


@orders_bp.route("/orders/<order_id>", methods=["DELETE"])
@require_auth
def delete_order(order_id):
    """Delete an existing order."""
    order = data.orders.get(order_id)
    if order is None:
        return jsonify({"error": "Order not found."}), 404

    if order["createdBy"] != request.client_token:
        return jsonify({"error": "Order not found."}), 404

    del data.orders[order_id]
    return "", 204
