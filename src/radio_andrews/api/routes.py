"""API endpoints."""

import json
from datetime import datetime
from pathlib import Path

from flask import Blueprint, current_app, jsonify

api = Blueprint("api", __name__, url_prefix="/api")


def read_current_track() -> dict:
    """Read current track info from JSON file."""
    track_file: Path = current_app.config["CURRENT_TRACK_FILE"]

    if not track_file.exists():
        return {
            "title": "Unknown",
            "artist": "Unknown",
            "filename": "",
            "started_at": 0,
        }

    try:
        with open(track_file) as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError):
        return {
            "title": "Unknown",
            "artist": "Unknown",
            "filename": "",
            "started_at": 0,
        }


@api.route("/current")
def current_track():
    """Get current playing track.

    Returns:
        JSON with track info: title, artist, started_at, elapsed
    """
    track = read_current_track()

    # Calculate elapsed time
    started_at = track.get("started_at", 0)
    if started_at > 0:
        elapsed = int(datetime.now().timestamp()) - started_at
    else:
        elapsed = 0

    return jsonify({
        "title": track.get("title", "Unknown"),
        "artist": track.get("artist", "Unknown"),
        "filename": track.get("filename", ""),
        "started_at": started_at,
        "elapsed": elapsed,
    })


@api.route("/health")
def health():
    """Health check endpoint."""
    return jsonify({"status": "ok"})
