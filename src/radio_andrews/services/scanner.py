"""Music scanner service."""

from pathlib import Path

from mutagen.easyid3 import EasyID3
from mutagen.mp3 import MP3

from radio_andrews.models import Track, db


def get_mp3_metadata(filepath: Path) -> dict:
    """Extract metadata from MP3 file.

    Args:
        filepath: Path to MP3 file.

    Returns:
        Dictionary with title, artist, duration.
    """
    try:
        audio = MP3(filepath, ID3=EasyID3)
        title = audio.get("title", [filepath.stem])[0]
        artist = audio.get("artist", ["Unknown"])[0]
        duration = int(audio.info.length)
    except Exception:
        # Fallback if metadata cannot be read
        title = filepath.stem
        artist = "Unknown"
        duration = 0

    return {
        "title": title,
        "artist": artist,
        "duration": duration,
    }


def scan_music_folder(folder: Path) -> dict:
    """Scan music folder and add tracks to database.

    Args:
        folder: Path to music folder.

    Returns:
        Dictionary with scan results.
    """
    if not folder.exists():
        return {"error": "Folder does not exist", "added": 0, "skipped": 0}

    added = 0
    skipped = 0
    errors = []

    for filepath in folder.glob("*.mp3"):
        # Check if track already exists
        existing = Track.query.filter_by(filename=str(filepath)).first()
        if existing:
            skipped += 1
            continue

        try:
            metadata = get_mp3_metadata(filepath)
            track = Track(
                filename=str(filepath),
                title=metadata["title"],
                artist=metadata["artist"],
                duration=metadata["duration"],
            )
            db.session.add(track)
            added += 1
        except Exception as e:
            errors.append(f"{filepath.name}: {e}")

    db.session.commit()

    return {
        "added": added,
        "skipped": skipped,
        "errors": errors,
    }
