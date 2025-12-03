# Radio Andrews - Liquidsoap configuration
# Plays music and writes current track info to JSON file

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

# Write track info when track changes
def on_track_change(m)
    # Get metadata
    title = m["title"]
    artist = m["artist"]
    filename = m["filename"]
    
    # Use filename as title if title is empty
    display_title = if title == "" then filename else title end
    display_artist = if artist == "" then "Unknown" else artist end
    
    # Get current timestamp
    timestamp = int_of_float(time())
    
    # Build JSON
    data = '{"title": "#{display_title}", "artist": "#{display_artist}", "filename": "#{filename}", "started_at": #{timestamp}}'
    
    log("Now playing: #{display_artist} - #{display_title}")
    
    # Write to file (ignore result)
    ignore(file.write(data=data, "/shared/current_track.json"))
end

# Register callback
radio.on_track(on_track_change)

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
