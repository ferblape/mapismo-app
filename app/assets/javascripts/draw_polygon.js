// Code from
// http://obeattie.github.com/gmaps-radius/
function getPoints(lat, lng, radius, earth){
    // Returns an array of GLatLng instances representing the points of the radius circle
    var lat = (lat * Math.PI) / 180; //rad
    var lon = (lng * Math.PI) / 180; //rad
    var d = parseFloat(radius) / earth; // d = angular distance covered on earth's surface
    var points = [];
    for (x = 0; x <= 360; x++)
    {
        brng = x * Math.PI / 180; //rad
        var destLat = Math.asin(Math.sin(lat)*Math.cos(d) + Math.cos(lat)*Math.sin(d)*Math.cos(brng));
        var destLng = ((lon + Math.atan2(Math.sin(brng)*Math.sin(d)*Math.cos(lat), Math.cos(d)-Math.sin(lat)*Math.sin(destLat))) * 180) / Math.PI;
        destLat = (destLat * 180) / Math.PI;
        points.push(new google.maps.LatLng(destLat, destLng));
    }
    return points;
}

function polygonDestructionHandler(polygon) {
  polygon.setMap(null);
  return polygon;
}

function polygonDrawHandler(polygon, position) {
    // Get the desired radius + units
    var earth = 6378100;
    var radius = parseFloat($('#map_radius').val());
    // Draw the polygon
    var points = getPoints(position.lat(), position.lng(), radius, earth);
    if(polygon == null){
      polygon = new google.maps.Polygon({
          paths: points,
          strokeColor: '#004de8',
          strokeWeight: 1,
          strokeOpacity: 0.62,
          fillColor: '#004de8',
          fillOpacity: 0.07,
          geodesic: true,
          map: carto_embed_map
      });
    } else {
      polygon.setPaths(points);
      polygon.setMap(carto_embed_map);
      polygon.setVisible(true);
      polygon.setVisible(true);
    }
    return polygon;
}