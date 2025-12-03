"""CLI commands."""

import click
from flask import current_app

from radio_andrews.models import Track, db
from radio_andrews.services.scanner import scan_music_folder


def register_cli(app):
    """Register CLI commands with Flask app."""

    @app.cli.command("init-db")
    def init_db():
        """Initialize database tables."""
        db.create_all()
        click.echo("Database initialized.")

    @app.cli.command("scan-music")
    def scan_music():
        """Scan music folder and add tracks to database."""
        folder = current_app.config["MUSIC_FOLDER"]
        click.echo(f"Scanning {folder}...")

        result = scan_music_folder(folder)

        if "error" in result:
            click.echo(f"Error: {result['error']}")
            return

        click.echo(f"Added: {result['added']}")
        click.echo(f"Skipped: {result['skipped']}")

        if result["errors"]:
            click.echo("Errors:")
            for error in result["errors"]:
                click.echo(f"  - {error}")

    @app.cli.command("list-tracks")
    def list_tracks():
        """List all tracks in database."""
        tracks = Track.query.all()

        if not tracks:
            click.echo("No tracks in database. Run 'scan-music' first.")
            return

        click.echo(f"Total tracks: {len(tracks)}\n")
        for track in tracks:
            duration = f"{track.duration // 60}:{track.duration % 60:02d}"
            click.echo(f"  [{track.id}] {track.artist} - {track.title} ({duration})")
