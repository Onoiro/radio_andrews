"""Application configuration."""

import os
from pathlib import Path


class Config:
    """Base configuration."""

    # Path to file where Liquidsoap writes current track info
    CURRENT_TRACK_FILE = Path(
        os.getenv("CURRENT_TRACK_FILE", "/shared/current_track.json")
    )

    # Database
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL", "sqlite:///data/radio.db"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Music folder
    MUSIC_FOLDER = Path(os.getenv("MUSIC_FOLDER", "/music"))

    DEBUG = os.getenv("FLASK_DEBUG", "0") == "1"


class DevelopmentConfig(Config):
    """Development configuration."""

    DEBUG = True
    CURRENT_TRACK_FILE = Path(
        os.getenv("CURRENT_TRACK_FILE", "shared/current_track.json")
    )
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL", "sqlite:///data/radio.db"
    )
    MUSIC_FOLDER = Path(os.getenv("MUSIC_FOLDER", "music"))


class TestingConfig(Config):
    """Testing configuration."""

    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    CURRENT_TRACK_FILE = Path("/tmp/test_current_track.json")
    MUSIC_FOLDER = Path("/tmp/test_music")


def get_config() -> Config:
    """Get configuration based on environment."""
    env = os.getenv("FLASK_ENV", "production")
    if env == "development":
        return DevelopmentConfig()
    if env == "testing":
        return TestingConfig()
    return ProductionConfig()


class ProductionConfig(Config):
    """Production configuration."""

    DEBUG = False
