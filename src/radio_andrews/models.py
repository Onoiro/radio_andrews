"""Database models."""

from datetime import datetime

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Track(db.Model):
    """Music track information."""

    __tablename__ = "tracks"

    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(500), unique=True, nullable=False)
    title = db.Column(db.String(255), nullable=False)
    artist = db.Column(db.String(255), default="Unknown")
    duration = db.Column(db.Integer, default=0)  # seconds
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationship to play history
    plays = db.relationship("PlayHistory", backref="track", lazy=True)

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "id": self.id,
            "filename": self.filename,
            "title": self.title,
            "artist": self.artist,
            "duration": self.duration,
            "play_count": len(self.plays),
        }


class PlayHistory(db.Model):
    """Track play history."""

    __tablename__ = "play_history"

    id = db.Column(db.Integer, primary_key=True)
    track_id = db.Column(db.Integer, db.ForeignKey("tracks.id"), nullable=False)
    played_at = db.Column(db.DateTime, default=datetime.utcnow)
