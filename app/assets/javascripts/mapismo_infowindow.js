/**
 * Mapismo Infowindow
 * Needed:
 *  user_name, table_name, map_canvas, map_key??(no)
 **/

function MapismoInfowindow(params) {
  this.latlng_ = new google.maps.LatLng(0,0);
  this.feature_;
  this.map_ = params.cartodb_map;
  this.columns_;
  this.offsetHorizontal_ = -107;
  this.width_ = 214;
  this.setMap(params.cartodb_map);
  this.params_ = params;
  this.getActiveColumns(params);
};

MapismoInfowindow.prototype = new google.maps.OverlayView();

MapismoInfowindow.prototype.getActiveColumns = function(params) {
  var that = this;
  $.ajax({
    url: TILEHTTP + '://' + params.cartodb_user_name + '.' + TILESERVER + '/tiles/' + params.cartodb_table_name + '/infowindow?'+ 'map_key=' + (params.cartodb_map_key || '')+'&callback=?',
    dataType: 'jsonp',
    success:function(result){
      var columns = $.parseJSON(result.infowindow);
      if (columns) {
        that.columns_ = parseColumns(columns);
      } else {
        $.ajax({
          // If the table is private, you can't run any api methods without being
          method:'get',
          url: TILEHTTP + '://'+ that.params_.cartodb_user_name + '.' +  SQL_SERVER + '/api/v1/sql/?q='+escape('select * from '+ that.params_.cartodb_table_name + ' LIMIT 1'),
          dataType: 'jsonp',
          success: function(columns) {
            that.columns_ = parseColumns(columns.rows[0]);
          },
          error: function(e) {}
        });
      }

    },
    error: function(e){}
  });
  
  function parseColumns(columns) {
    var str = '';
    for (p in columns) {
      if (columns[p] && p!='the_geom_webmercator' && p!='the_geom') {
        str+=p+',';
      }
    }
    return str.substr(0,str.length-1);
  }
}

MapismoInfowindow.prototype.open = function(feature){
  var that = this;
  that.feature_ = feature;
  
  console.log(feature);
  
  // If the table is private, you can't run any api methods without being
  $.ajax({
    method:'get',
    url: TILEHTTP + '://'+ this.params_.cartodb_user_name + '.' + SQL_SERVER + '/api/v1/sql/?q='+escape('select '+that.columns_+' from '+ this.params_.cartodb_table_name + ' where cartodb_id=' + feature)+'&callback=?',
    dataType: 'jsonp',
    success: function(result) {
      positionateInfowindow(result.rows[0]);
    },
    error: function(e) {}
  });
 
  function positionateInfowindow(variables) {
    if (that.div_) {
      var div = that.div_;
              
      // Remove the list items
      $('div.cartodb_infowindow div.outer_top div.top').html('');

      for (p in variables) {
        if (p!='cartodb_id' && p!='cdb_centre') {
          $('div.cartodb_infowindow div.outer_top div.top').append('<label>'+p+'</label><p class="'+((variables[p]!=null)?'':'empty')+'">'+(variables[p] || 'empty')+'</p>');
        }
      }
      
      $('div.cartodb_infowindow div.bottom label').html('id: <strong>'+feature+'</strong>');
      // that.moveMaptoOpen();
      // that.setPosition();     
    }
  }
}

MapismoInfowindow.prototype.draw = function() {
  var me = this;
  
  var div = this.div_;
  if (!div) {
    div = this.div_ = document.createElement('DIV');
    div.className = "cartodb_infowindow";

    div.innerHTML = '<a href="#close" class="close">x</a>'+
                    '<div class="outer_top">'+
                      '<div class="top">'+
                      '</div>'+
                    '</div>'+
                    '<div class="bottom">'+
                      '<label>id:1</label>'+
                    '</div>';
    
    $(div).find('a.close').click(function(ev){
      ev.preventDefault();
      ev.stopPropagation();
      me.hide();
    });

    google.maps.event.addDomListener(div, 'click', function (ev) {
      ev.preventDefault ? ev.preventDefault() : ev.returnValue = false;
    });
    google.maps.event.addDomListener(div, 'dblclick', function (ev) {
      ev.preventDefault ? ev.preventDefault() : ev.returnValue = false;
    });
    google.maps.event.addDomListener(div, 'mousedown', function (ev) {
      ev.preventDefault ? ev.preventDefault() : ev.returnValue = false;
      ev.stopPropagation ? ev.stopPropagation() : window.event.cancelBubble = true;
    });
    google.maps.event.addDomListener(div, 'mouseup', function (ev) {
      ev.preventDefault ? ev.preventDefault() : ev.returnValue = false;
    });
    google.maps.event.addDomListener(div, 'mousewheel', function (ev) {
    	ev.stopPropagation ? ev.stopPropagation() : window.event.cancelBubble = true;
    });
    google.maps.event.addDomListener(div, 'DOMMouseScroll', function (ev) {
    	ev.stopPropagation ? ev.stopPropagation() : window.event.cancelBubble = true;
    });
    
    var panes = this.getPanes();
    panes.floatPane.appendChild(div);

    div.style.opacity = 0;
  }

  var pixPosition = this.getProjection().fromLatLngToDivPixel(this.latlng_);
  if (pixPosition) {
    div.style.width = this.width_ + 'px';
    div.style.left = (pixPosition.x - 49) + 'px';
    var actual_height = - $(div).height();
    div.style.top = (pixPosition.y + actual_height + 5) + 'px';
  }
}
