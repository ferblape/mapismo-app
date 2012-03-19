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

/************ CartoDB Stuff ********************/


// Zoom to your geometries
function getCartoDBBBox() {
  $.ajax({
    method: "GET",
    url: TILEHTTP + '://'+cartodb_user_name+'.' + SQL_SERVER + global_api_url+ 'sql/?q='+escape('select ST_Extent(the_geom) from '+ cartodb_table_name),
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


// Wax interaction
function addCartoDBInteraction(params) {
  var currentCartoDbId,
      tilejson = generateTileJson(params);
      infowindow = new CartoDBInfowindow(params);
      cache_buster = 0;

  var waxOptions = {
    callbacks: {
      out: function(){
        params.cartodb_map.setOptions({draggableCursor: 'default'});
      },
      over: function(feature, div, opt3, evt){
        params.cartodb_map.setOptions({draggableCursor: 'pointer'});
      },
      click: function(feature, div, opt3, evt){
        infowindow.open(feature,evt.latLng);
      }
    },
    clickAction: 'full'
  };

  var wax_tile = new wax.g.connector(tilejson);
  params.cartodb_map.overlayMapTypes.insertAt(0,wax_tile);
  var interaction = wax.g.interaction(params.cartodb_map, tilejson, waxOptions);


  // Generate tilejson
  function generateTileJson(params) {
    var core_url = TILEHTTP + '://' + params.cartodb_user_name + '.' + TILESERVER;
    var base_url = core_url + '/tiles/' + params.cartodb_table_name + '/{z}/{x}/{y}';
    var tile_url = base_url + '.png?cache_buster=0';
    var grid_url = base_url + '.grid.json';

    // SQL?
    if (params.cartodb_sql) {
      var query = 'sql=' + params.cartodb_sql;
      tile_url = wax.util.addUrlData(tile_url, query);
      grid_url = wax.util.addUrlData(grid_url, query);
    }

    // Style
    if (params.cartodb_style) {
      var style = 'style=' + params.cartodb_style;
      tile_url = wax.util.addUrlData(tile_url,style);
      grid_url = wax.util.addUrlData(grid_url,style);
    }


    // Build up the tileJSON
    return {
      blankImage: TILEHTTP + '://cartodb.s3.amazonaws.com/embed/blank_tile.png',
      tilejson: '1.0.0',
      scheme: 'xyz',
      tiles: [tile_url],
      grids: [grid_url],
      tiles_base: tile_url,
      grids_base: grid_url,
      formatter: function(options, data) {
          currentCartoDbId = data.cartodb_id;
          return data.cartodb_id;
      },
      cache_buster: function(){
          return params.cache_buster;
      }
    };
  };
};

/**************** Mapismo stuff **************************/


function newMap(){
  return({

    _formatDateLong: function(date){
      if(date != null) {
        return date.getFullYear() + '-' + parseInt(date.getMonth()+1) + '-' + date.getDate();
      } else {
        return "";
      }
    },

    _formatTimeLong: function(time){
      if(time != null) {
        return '+' + time.getHours() + ':' + time.getMinutes() + ':' + time.getUTCSeconds();
      } else {
        return "";
      }
    },

    _formatDateShort: function(date){
      if(date != null) {
        var day = date.getDate();
        var ordinal = "th";
        if(day == 1) { ordinal = 'st' };
        if(day == 2) { ordinal = 'nd' };
        if(day == 3) { ordinal = 'rd' };
        return date.getShortMonthName() + ' ' + day + ordinal;
      } else {
        return "";
      }
    },

    parentElement: function(){
      return $('header#top_bar');
    },

    readyForSaving: function(){
      if($('input#map_keywords').val().trim() == ""){
        return false
      }
      if($('input#map_location_name').val().trim() == ""){
        return false
      }
      if($('input#map_start_date').val().trim() == ""){
        return false
      }
      if($('input#map_end_date').val().trim() == ""){
        return false
      }
      return true;
    },

    updatePopoverPositions: function(){
      var left = this.parentElement().find('a:eq(0)').position().left;
      var width = this.parentElement().find('a:eq(0)').width() / 2;
      $('.popover.what').css('left', left + width - $('.popover.what').width()/2);

      left = this.parentElement().find('a:eq(1)').position().left;
      width = this.parentElement().find('a:eq(1)').width() / 2;
      $('.popover.where').css('left', left + width - $('.popover.where').width()/2);

      left = this.parentElement().find('a:eq(2)').position().left;
      width = this.parentElement().find('a:eq(2)').width() / 2;
      $('.popover.when').css('left', left + width - $('.popover.when').width()/2);
    },

    updateKeywordList: function(){
      $('ul#keywords_list').html('');
      $('input#map_keywords').val().split(",").forEach(function(keyword){
        var li = $('<li/>');
        li.html(keyword + ' <a href="#" class="delete">Remove</a>').
           appendTo($('ul#keywords_list'));
      });
    },

    removeKeyword: function(keyword){
      var val = $('input#map_keywords').val().split(",").filter(function(element, index, array){
        return (element != keyword.trim());
      });
      $('input#map_keywords').val(val);
      this.updateMapBar();
      this.enableKeywordInput();
    },

    disableKeywordInput: function(){
      $('#new_keyword').attr('disabled', 'disabled');
      $('#new_keyword').attr('placeholder', 'Only 3 keywords are allowed');
    },

    enableKeywordInput: function(){
      $('#new_keyword').attr('disabled', null);
      $('#new_keyword').attr('placeholder', null);
    },

    addKeyword: function(keyword){
      keyword = keyword.split(",")[0].trim();
      if(keyword == ""){
        return;
      }
      var val;
      if($('input#map_keywords').val().trim() == ""){
        val = [];
      } else {
        val = $('input#map_keywords').val().split(",");
      }
      if(val.length < 3) {
        val.push(keyword)
        $('input#map_keywords').val(val.join(","));
        this.updateKeywordList();
        this.updateMapBar();
        if(val.length == 3){
          this.disableKeywordInput();
        }
      }
    },

    whatValues: function(sources, keywords){
      $('.popover.what .social_networks label').removeClass('selected');
      sources.forEach(function(source){
        var str;
        switch(source) {
          case "flickr":
            $('.popover.what input[value=flickr]').attr('checked','checked');
            $('.popover.what label.flickr').addClass('selected');
            break;
          case "instagram":
            $('.popover.what input[value=instagram]').attr('checked','checked');
            $('.popover.what label.instagram').addClass('selected');
            break;
          case "twitter":
            $('.popover.what input[value=twitter]').attr('checked','checked');
            $('.popover.what label.twitter').addClass('selected');
            break;
        };
      });
      $('input#map_keywords').val(keywords.join(","));
      this.updateKeywordList();
    },

    whereValue: function(value){
      $('input#map_location_name').val(value);
      this.updateMapBar();
    },

    setWhenValues: function(){
      $('#map_start_date').val(this._formatDateLong($('#from_day').datepicker('getDate'))+
                                this._formatTimeLong($.timePicker("#from_time").getTime()));
      $('#map_end_date').val(this._formatDateLong($('#to_day').datepicker('getDate'))+
                              this._formatTimeLong($.timePicker("#to_time").getTime()));
    },

    updateMapBar: function(){
      var parsedValue = "";
      if($('.popover.what input[value=twitter]').is(':checked')){
        parsedValue += "Tweets";
      }
      if($('.popover.what input[value=flickr]').is(':checked')){
        (parsedValue == "") ? parsedValue += "Flickr" : parsedValue += ", Flickr"
      }
      if($('.popover.what input[value=instagram]').is(':checked')){
        (parsedValue == "") ? parsedValue += "Instagram photos" : parsedValue += " and Instagram photos"
      } else {
        if(parsedValue != ""){
          parsedValue += " photos";
        }
      }

      parsedValue += " about ";
      // TODO: the last ',' should be 'and'
      parsedValue += $('input#map_keywords').val().split(",").join(", ");

      this.parentElement().find('a:eq(0)').html(parsedValue);
      this.parentElement().find('a:eq(1)').html($('input#map_location_name').val());

      if(this.readyForSaving()){
        $('.save_bar').show();
        $('#top_bar a.button').attr('disabled', null);
      } else {
        $('.save_bar').hide();
        $('#top_bar a.button').attr('disabled', 'disabled');
      }

      var fromDate = this._formatDateShort($('#from_day').datepicker('getDate'));
      var toDate = this._formatDateShort($('#to_day').datepicker('getDate'));
      this.parentElement().find('a:eq(2)').html(fromDate + ' - ' + toDate);

      this.updatePopoverPositions();

      var name = "";
      $('#top_bar').text().split('\n').forEach(function(s){
        s = s.trim();
        if(s != "Go" && s != ""){
          name += s + " ";
        }
      });
      $('#map_name').val(name.trim().replace("Creating a map with ", ""));
    },

    initMapValues: function(){
      this.whatValues(['flickr','instagram'], ['football','15m']);
      this.whereValue('Madrid');
    },
    map: null,
    geocoder: null,

    initDOM: function(carto_embed_map){
      var that = this;

      $('.popover').hide();
      $('.popover.what').show();
      $('.save_bar').hide();

      // radius slider
      $('#radius-picker').slider({
        range: 'min',
        min: 50,
        max: 5000,
        step: 50,
        value: $('#map_radius').val(),
        slide: function(event, ui){
          $('#radius').html(ui.value + " meters");
        }
      });

      $('#radius').html($('#map_radius').val() + " meters");

      // Date pickers
      $('#from_day').datepicker({
        dateFormat: 'yy-mm-dd',
        maxDate: '+0',
        onSelect: function(dateText, inst) {
          var toDate = new Date($('#to_day').datepicker('getDate'));
          var fromDate = new Date(dateText);
          if(fromDate > toDate){
            $('#to_day').datepicker('setDate', that._formatDateLong(new Date(new Date().setDate(fromDate.getDate() +2))));
          }
          that.updateMapBar();
          that.setWhenValues();
        }
      });
      $('#to_day').datepicker({
        dateFormat: 'yy-mm-dd',
        maxDate: '+0',
        onSelect: function(dateText, inst) {
          that.updateMapBar();
          that.setWhenValues();
        }
      });

      var toDate = new Date();
      var fromDate = new Date();
      fromDate.setDate(fromDate.getDate() - 1);
      $('#from_day').datepicker('setDate', this._formatDateLong(fromDate));
      $('#to_day').datepicker('setDate', this._formatDateLong(toDate));

      // Time pickers
      $("#from_time, #to_time").timePicker();
      $.timePicker("#from_time").setTime('00:00');
      $.timePicker("#to_time").setTime('00:00');

      $("#from_time, #to_time").on({
        change: function(){
          that.setWhenValues();
        }
      });
      this.setWhenValues();

      this.updateMapBar();

      // handle keyboard strokes
      $(document).keyup(function(e) {
        // escape key
        if(e.keyCode == 27) {
          $('.popover').hide();
          e.preventDefault(); e.stopPropagation();
        }
        if(e.keyCode == 13){
          if($('input#new_keyword').is(":focus")){
            that.addKeyword($('input#new_keyword').val());
            $('input#new_keyword').val('');
          }
          if($('input#map_location_name').is(":focus")){
            that.whereValue($('input#map_location_name').val());
          }
        }
      });

      this.parentElement().find('a[data-type=what]').on({
        click: function(e){
          $('.popover.where, .popover.when').hide();
          $('.popover.what').toggle();
          that.parentElement().find('a').removeClass('selected');
          if($('.popover.what').is(':visible')){
            $(this).addClass('selected');
          }
          $('#new_keyword').focus();
          e.preventDefault(); e.stopPropagation();
        }
      });

      this.parentElement().find('a[data-type=where]').on({
        click: function(e){
          $('.popover.what, .popover.when').hide();
          $('.popover.where').toggle();
          that.parentElement().find('a').removeClass('selected');
          if($('.popover.where').is(':visible')){
            $(this).addClass('selected');
          }
          $('#map_location_name').focus();
          e.preventDefault(); e.stopPropagation();
        }
      });

      this.parentElement().find('a[data-type=when]').on({
        click: function(e){
          $('.popover.where, .popover.what').hide();
          $('.popover.when').toggle();
          that.parentElement().find('a').removeClass('selected');
          if($('.popover.when').is(':visible')){
            $(this).addClass('selected');
          }
          e.preventDefault(); e.stopPropagation();
        }
      });

      $('.popover.what input').on({
        change: function(e){
          that.updateMapBar();
          if($(this).is(':checked')){
            $(this).parents('label').addClass('selected');
          } else {
            $(this).parents('label').removeClass('selected');
          }
          e.preventDefault(); e.stopPropagation();
        }
      });

      $('ul#keywords_list').on('click', 'a.delete', function(e){
        var parent = $(this).parents('li');
        that.removeKeyword(parent.text().replace("Remove", ""));
        parent.remove();
        e.preventDefault(); e.stopPropagation();
      });

      $('a.button').on({
        click: function(e){
          if($(this).parents('form').length > 0){
            $(this).parents('form').submit();
          }
        }
      });
    }
  });
}

var MAPISMO = {
  newMap: newMap()
};