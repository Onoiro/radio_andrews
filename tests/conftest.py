"""Pytest configuration and fixtures."""

import pytest

from radio_andrews.app import create_app
from radio_andrews.config import Config


class TestConfig(Config):
    """Test configuration."""
    
    TESTING = True
    DEBUG = True


@pytest.fixture
def app():
    """Create test application."""
    app = create_app(TestConfig())
    return app


@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()
