from flask import Blueprint, request, jsonify
import uuid
from store import data

clients_bp = Blueprint("clients", __name__)


@clients_bp.route("/api-clients", methods=["POST"])
def register_client():
    """Register a new API client with name, email, and password."""
    body = request.get_json(silent=True) or {}

    client_name = body.get("clientName")
    client_email = body.get("clientEmail")
    client_password = body.get("clientPassword")

    # Validate required fields
    missing = []
    if not client_name:
        missing.append("clientName")
    if not client_email:
        missing.append("clientEmail")
    if not client_password:
        missing.append("clientPassword")

    if missing:
        return jsonify({"error": f"Missing required fields: {', '.join(missing)}"}), 400

    # Check for duplicate
    if client_email in data.clients:
        return (
            jsonify({"error": "API client already registered. Try a different email."}),
            409,
        )

    # Create client
    access_token = str(uuid.uuid4())
    data.clients[client_email] = {
        "clientName": client_name,
        "clientEmail": client_email,
        "clientPassword": client_password,
        "accessToken": access_token,
    }

    return jsonify({"accessToken": access_token}), 201


@clients_bp.route("/api-clients/login", methods=["POST"])
def login_client():
    """Login with email and password to retrieve access token."""
    body = request.get_json(silent=True) or {}

    client_email = body.get("clientEmail")
    client_password = body.get("clientPassword")

    # Validate required fields
    missing = []
    if not client_email:
        missing.append("clientEmail")
    if not client_password:
        missing.append("clientPassword")

    if missing:
        return jsonify({"error": f"Missing required fields: {', '.join(missing)}"}), 400

    # Find client
    client = data.clients.get(client_email)
    if client is None or client["clientPassword"] != client_password:
        return jsonify({"error": "Invalid email or password."}), 401

    return jsonify({"accessToken": client["accessToken"]}), 200

