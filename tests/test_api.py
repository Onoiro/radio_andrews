"""API endpoint tests."""


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
    assert "started_at" in data
    