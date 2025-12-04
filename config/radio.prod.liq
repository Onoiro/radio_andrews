# Radio Andrews - Production configuration

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
    title = m["title"]
    artist = m["artist"]
    filename = m["filename"]
    
    display_title = if title == "" then filename else title end
    display_artist = if artist == "" then "Unknown" else artist end
    
    timestamp = int_of_float(time())
    
    data = '{"title": "#{display_title}", "artist": "#{display_artist}", "filename": "#{filename}", "started_at": #{timestamp}}'
    
    log("Now playing: #{display_artist} - #{display_title}")
    
    ignore(file.write(data=data, "/shared/current_track.json"))
end

radio.on_track(on_track_change)

# Get password from environment or use default
source_password = environment.get("ICECAST_SOURCE_PASSWORD")
source_password = if source_password == "" then "changeme" else source_password end

# Output to Icecast
output.icecast(
    %mp3(bitrate=192),
    host="icecast",
    port=8000,
    password=source_password,
    mount="/stream",
    name="Radio Andrews",
    description="My personal radio station",
    radio
)
