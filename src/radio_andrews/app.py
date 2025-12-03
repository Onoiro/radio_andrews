"""Flask application factory."""

from flask import Flask
from flask_cors import CORS

from radio_andrews.api.routes import api
from radio_andrews.config import get_config


def create_app(config=None) -> Flask:
    """Create and configure Flask application.

    Args:
        config: Optional configuration object for testing.

    Returns:
        Configured Flask application.
    """
    app = Flask(__name__)

    # Load configuration
    if config is None:
        config = get_config()

    app.config.from_object(config)

    # Enable CORS for all routes
    CORS(app)

    # Register blueprints
    app.register_blueprint(api)

    # Root endpoint
    @app.route("/")
    def index():
        return {"name": "Radio Andrews API", "version": "0.1.0"}

    return app
