from flask import Blueprint, jsonify

status_bp = Blueprint("status", __name__)


@status_bp.route("/status", methods=["GET"])
def get_status():
    """Health check endpoint."""
    return jsonify({"status": "OK"}), 200
