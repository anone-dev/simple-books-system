"""Authentication middleware for protected endpoints."""

from functools import wraps
from flask import request, jsonify
from store import data


def require_auth(f):
    """Decorator that validates Bearer token from Authorization header."""

    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")

        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Missing or invalid access token."}), 401

        token = auth_header[7:]  # Strip "Bearer "

        # Find client by token
        client_email = None
        for email, client in data.clients.items():
            if client["accessToken"] == token:
                client_email = email
                break

        if client_email is None:
            return jsonify({"error": "Missing or invalid access token."}), 401

        # Attach client info to request context
        request.client_email = client_email
        request.client_token = token
        return f(*args, **kwargs)

    return decorated
