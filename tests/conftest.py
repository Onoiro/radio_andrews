"""Pytest configuration and fixtures."""

import pytest

from radio_andrews.app import create_app
from radio_andrews.config import TestingConfig
from radio_andrews.models import db


@pytest.fixture
def app():
    """Create test application."""
    app = create_app(TestingConfig())

    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()


@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()
