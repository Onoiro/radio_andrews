"""API endpoints."""

import json
from datetime import datetime
from pathlib import Path

from flask import Blueprint, current_app, jsonify

from radio_andrews.models import Track, PlayHistory, db

api = Blueprint("api", __name__, url_prefix="/api")


def read_current_track_file() -> dict:
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
        JSON with track info.
    """
    data = read_current_track_file()

    # Calculate elapsed time
    started_at = data.get("started_at", 0)
    if started_at > 0:
        elapsed = int(datetime.now().timestamp()) - started_at
    else:
        elapsed = 0

    # Try to find track in database for extra info
    filename = data.get("filename", "")
    track = Track.query.filter_by(filename=filename).first()

    response = {
        "title": data.get("title", "Unknown"),
        "artist": data.get("artist", "Unknown"),
        "filename": filename,
        "started_at": started_at,
        "elapsed": elapsed,
    }

    if track:
        response["id"] = track.id
        response["duration"] = track.duration
        response["play_count"] = len(track.plays)

    return jsonify(response)


@api.route("/tracks")
def list_tracks():
    """Get list of all tracks.

    Returns:
        JSON array of tracks.
    """
    tracks = Track.query.order_by(Track.artist, Track.title).all()
    return jsonify([track.to_dict() for track in tracks])


@api.route("/tracks/<int:track_id>")
def get_track(track_id: int):
    """Get track by ID.

    Args:
        track_id: Track ID.

    Returns:
        JSON with track info or 404.
    """
    track = db.get_or_404(Track, track_id)
    return jsonify(track.to_dict())


@api.route("/health")
def health():
    """Health check endpoint."""
    return jsonify({"status": "ok"})
