# Radio Andrews - Liquidsoap 2.x configuration
# Минимальная версия - просто играем музыку

# Настройки логирования
settings.log.file := false
settings.log.stdout := true
settings.log.level := 2

# Плейлист из папки /music
radio = playlist(
    mode="randomize",
    reload=3600,
    "/music"
)

# Fallback на тишину если плейлист пуст
radio = fallback(track_sensitive=false, [radio, blank()])

# Вывод в Icecast
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
