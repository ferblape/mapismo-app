// Zoom to your geometries
function getCartoDBBBox(map_id, carto_embed_map) {
  var query = 'select ST_Extent(the_geom) from '+ cartodb_table_name;
  if(map_id != null){
    query += ' where map_id=' + map_id;
  }
  var url = TILEHTTP + '://'+cartodb_user_name+'.' + SQL_SERVER + global_api_url+ 'sql/?q='+ escape(query);
  $.ajax({
    method: "GET",
    url: url,
    dataType: 'jsonp',
    success: function(data) {
      if (data.rows[0].st_extent!=null) {
        var coordinates = data.rows[0].st_extent.replace('BOX(','').replace(')','').split(',');

        var coor1 = coordinates[0].split(' ');
        var coor2 = coordinates[1].split(' ');
        var bounds = new google.maps.LatLngBounds();

        // Check bounds
        if (coor1[0] >  180
         || coor1[0] < -180
         || coor1[1] >  90
         || coor1[1] < -90
         || coor2[0] >  180
         || coor2[0] < -180
         || coor2[1] >  90
         || coor2[1] < -90) {
          coor1[0] = '-30';
          coor1[1] = '-50';
          coor2[0] = '110';
          coor2[1] =  '80';
        }


        bounds.extend(new google.maps.LatLng(coor1[1],coor1[0]));
        bounds.extend(new google.maps.LatLng(coor2[1],coor2[0]));

        carto_embed_map.fitBounds(bounds);
      }

    },
    error: function(e) {}
  });
}

