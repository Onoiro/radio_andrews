"""API endpoint tests."""

from radio_andrews.models import Track, db


def test_root_endpoint(client):
    """Test root endpoint returns API info."""
    response = client.get("/")
    assert response.status_code == 200

    data = response.get_json()
    assert data["name"] == "Radio Andrews API"
    assert "version" in data


def test_health_endpoint(client):
    """Test health check endpoint."""
    response = client.get("/api/health")
    assert response.status_code == 200

    data = response.get_json()
    assert data["status"] == "ok"


def test_current_track_endpoint(client):
    """Test current track endpoint returns expected fields."""
    response = client.get("/api/current")
    assert response.status_code == 200

    data = response.get_json()
    assert "title" in data
    assert "artist" in data
    assert "elapsed" in data


def test_list_tracks_empty(client):
    """Test tracks list when database is empty."""
    response = client.get("/api/tracks")
    assert response.status_code == 200

    data = response.get_json()
    assert data == []


def test_list_tracks(client, app):
    """Test tracks list with data."""
    with app.app_context():
        track = Track(
            filename="/music/test.mp3",
            title="Test Track",
            artist="Test Artist",
            duration=180,
        )
        db.session.add(track)
        db.session.commit()

    response = client.get("/api/tracks")
    assert response.status_code == 200

    data = response.get_json()
    assert len(data) == 1
    assert data[0]["title"] == "Test Track"
    assert data[0]["artist"] == "Test Artist"


def test_get_track(client, app):
    """Test get single track."""
    with app.app_context():
        track = Track(
            filename="/music/test.mp3",
            title="Test Track",
            artist="Test Artist",
            duration=180,
        )
        db.session.add(track)
        db.session.commit()
        track_id = track.id

    response = client.get(f"/api/tracks/{track_id}")
    assert response.status_code == 200

    data = response.get_json()
    assert data["title"] == "Test Track"


def test_get_track_not_found(client):
    """Test get non-existing track."""
    response = client.get("/api/tracks/999")
    assert response.status_code == 404
