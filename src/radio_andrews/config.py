"""Application configuration."""

import os
from pathlib import Path


class Config:
    """Base configuration."""

    # Path to file where Liquidsoap writes current track info
    CURRENT_TRACK_FILE = Path(
        os.getenv("CURRENT_TRACK_FILE", "/shared/current_track.json")
    )

    # For local development
    DEBUG = os.getenv("FLASK_DEBUG", "0") == "1"


class DevelopmentConfig(Config):
    """Development configuration."""

    DEBUG = True
    CURRENT_TRACK_FILE = Path(
        os.getenv("CURRENT_TRACK_FILE", "data/current_track.json")
    )


class ProductionConfig(Config):
    """Production configuration."""

    DEBUG = False


def get_config() -> Config:
    """Get configuration based on environment."""
    env = os.getenv("FLASK_ENV", "production")
    if env == "development":
        return DevelopmentConfig()
    return ProductionConfig()
