# Radio Andrews - Liquidsoap configuration
# Simple version - just play music

# Logging settings
settings.log.file := false
settings.log.stdout := true
settings.log.level := 2

# Playlist from /music folder
radio = playlist(
    mode="randomize",
    reload=3600,
    "/music"
)

# Fallback to silence if playlist is empty
radio = fallback(track_sensitive=false, [radio, blank()])

# Output to Icecast
output.icecast(
    %mp3(bitrate=192),
    host="icecast",
    port=8000,
    password="radio_source_pwd",
    mount="/stream",
    name="Radio Andrews",
    description="My personal radio station",
    radio
)
