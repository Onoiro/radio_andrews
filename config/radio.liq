#!/usr/bin/liquidsoap

# Логирование
settings.log.file.set(false)
settings.log.stdout.set(true)
settings.log.level.set(3)

# Плейлист из папки /music
# mode="random" - случайный порядок
# reload=3600 - перезагрузка списка каждый час
radio = playlist(
    mode="randomize",
    reload=3600,
    "/music"
)

# Fallback на тишину если плейлист пуст
radio = fallback([radio, blank()])

# Callback при смене трека - пишем в файл для API
def on_track(m)
    title = m["title"]
    artist = m["artist"]
    filename = m["filename"]
    
    log("Now playing: #{artist} - #{title}")
    
    # Записываем текущий трек в JSON файл
    data = '{"title": "#{title}", "artist": "#{artist}", "filename": "#{filename}", "started_at": #{int_of_float(time())}}'
    file.write(data=data, "/shared/current_track.json")
end

radio = on_metadata(on_track, radio)

# Вывод в Icecast
output.icecast(
    %mp3(bitrate=192),
    host="icecast",
    port=8000,
    password="radio_source_pwd",
    mount="/stream",
    name="Radio Andrews",
    description="My personal radio station",
    genre="Mixed",
    url="http://localhost:8000",
    public=false,
    radio
)
