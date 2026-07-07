import sys
import os
from flask import Flask
from flask_cors import CORS


def get_static_folder():
    """Resolve static folder path for both dev and PyInstaller builds."""
    if getattr(sys, "_MEIPASS", None):
        return os.path.join(sys._MEIPASS, "static")
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")


def create_app():
    """Flask application factory."""
    app = Flask(__name__, static_folder=get_static_folder(), static_url_path="")
    CORS(app)

    # Register blueprints
    from routes.status import status_bp
    from routes.clients import clients_bp
    from routes.books import books_bp
    from routes.orders import orders_bp
    from routes.admin import admin_bp

    app.register_blueprint(status_bp)
    app.register_blueprint(clients_bp)
    app.register_blueprint(books_bp)
    app.register_blueprint(orders_bp)
    app.register_blueprint(admin_bp)

    # Serve Web UI at root
    @app.route("/")
    def serve_index():
        return app.send_static_file("index.html")

    return app


if __name__ == "__main__":
    app = create_app()
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)
