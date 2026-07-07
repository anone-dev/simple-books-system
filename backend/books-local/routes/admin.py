from flask import Blueprint, jsonify
from store import data

admin_bp = Blueprint("admin", __name__)


@admin_bp.route("/stock/reset", methods=["POST"])
def reset_stock():
    """Reset all book stock to initial values. Orders and clients preserved."""
    data.load_seed()
    return jsonify({"message": "Stock has been reset to initial values."}), 200


@admin_bp.route("/server/reset", methods=["POST"])
def reset_server():
    """Full server reset: stock + orders + clients cleared."""
    data.reset_all()
    return jsonify({"message": "Server has been reset. All data restored to initial state."}), 200
