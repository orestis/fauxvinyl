<html>
<head>
<style>
.album-container img{
    float: left;
    margin-right: 20px;
    height: 150px;
}

.album-container {
    font-size: 30px;
    overflow: auto;
    background: #cecece;
    margin: 0.5em;
    
    padding: 4px;
    font-family: sans-serif;
}

.album-list li a{
    text-decoration: none;
    color: #5e5e5e;
}

.artist {
    margin-top: 1em;
    margin-bottom: 0.5em;
}

.album {
    font-weight: 700;
}
</style>
<script src="/static/spotify-web-api.js"></script>
<script>
function getAlbumNode(album_info) {
    var artists = [];
    for (var i=0;i<album_info.artists.length;i++) {
        artists.push(album_info.artists[i].name);
    }


    var artist = "";
    if (artists.length > 0) {
        artist = artists.join(", ");
    }


    var name = album_info.name;

    var image = undefined;
    for (var i=0;i<album_info.images.length;i++) {
        var img = album_info.images[i];
        console.log(img);
        if (img.height > 100 && img.height < 500) {
            image = img.url;
        }
    }

    if (image) {
        image = '<img src="' + image + '">';
    } else {
        image = "";
    }


    return '<div class="album-container">' + image + '<div class="artist">' + artist + '</div>' + '<div class="album">' + name + '</div></div>';
    
};
</script>

</head>
<body>

<h1>Faux Vinyl</h1>
% if message:
<h2>{{message}}</h2>
% end
<ul class="album-list">
% for album in albums:
<li><a href="/play/{{album.uri}}" class="js-spotify-album" data-id="{{album.id}}">{{album.uri}}</a></li>
% end
</ul>
<script>
var spotifyApi = new SpotifyWebApi();
spotifyApi.getAlbums(['5U4W9E5WsYb2jUQWePT8Xm', '3KyVcddATClQKIdtaap4bV'])
  .then(function(data) {
    console.log('Albums information', data);
  }, function(err) {
    console.error(err);
  });

var uris = [];
var albums = document.getElementsByClassName('js-spotify-album');
for (var i=0;i<albums.length;i++) {
    var el = albums[i];
    var uri = el.getAttribute("data-id");
    spotifyApi.getAlbum(uri).then(function(data) {
        this.innerHTML = getAlbumNode(data);
        console.log('Album information', data);
    }.bind(el), function(err) {
        console.error(err);

    });
}

</script>
</body>

</html>