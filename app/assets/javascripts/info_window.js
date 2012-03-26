/**
 * CartoDB Infowindow
 * Needed:
 *  user_name, table_name, map_canvas, map_key??(no)
 **/

function CartoDBInfowindow(params) {
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

CartoDBInfowindow.prototype = new google.maps.OverlayView();

CartoDBInfowindow.prototype.getActiveColumns = function(params) {
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


CartoDBInfowindow.prototype.draw = function() {
  var me = this;

  var div = this.div_;
  if (!div) {
    div = this.div_ = $('#content');

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

    // var panes = this.getPanes();
    // panes.floatPane.appendChild(div);
    // div.style.opacity = 0;
  }

  // var pixPosition = this.getProjection().fromLatLngToDivPixel(this.latlng_);
  // if (pixPosition) {
  //   div.style.width = this.width_ + 'px';
  //   div.style.left = (pixPosition.x - 49) + 'px';
  //   var actual_height = - $(div).height();
  //   div.style.top = (pixPosition.y + actual_height + 5) + 'px';
  // }
};


CartoDBInfowindow.prototype.updateInfoWindow = function(row, feature){
  $('#current_feature').val(feature);
  $('#content .item_data img').attr('src', row.avatar_url);
  $('#content .item_data p strong').html(row.username);
  $('#content .item_data p span.date').html(this._formatDate(row.date));
  $('#content .item_data p a').html(row.source.capitaliseFirstLetter());
  $('#content .item_data p a').attr('href', row.permalink);
  var content = $('#content .content');
  content.removeClass('flickr').removeClass('instagram').removeClass('twitter');
  content.addClass(row.source);
  if(row.source == 'instagram' || row.source == 'flickr'){
    content.html('<img src="' + row.data + '" />');
  }
}

CartoDBInfowindow.prototype.updatePagination = function(feature, featureList){
  $('#content nav.pagination a.prev').removeClass('disabled');
  $('#content nav.pagination a.next').removeClass('disabled');

  if(featureList.indexOf(feature) == 0){
    $('#content nav.pagination a.prev').addClass('disabled');
  }
  if(featureList.indexOf(feature) == featureList.length-1){
    $('#content nav.pagination a.next').addClass('disabled');
  }
}

CartoDBInfowindow.prototype.open = function(feature,latlng,featureList){
  var that = this;
  that.feature_ = feature;
  that.latlng_ = latlng;

  // If the table is private, you can't run any api methods without being
  $.ajax({
    method:'get',
    url: TILEHTTP + '://'+ this.params_.cartodb_user_name + '.' + SQL_SERVER + '/api/v1/sql/?q='+escape('select '+that.columns_+' from '+ this.params_.cartodb_table_name + ' where cartodb_id=' + feature)+'&callback=?',
    dataType: 'jsonp',
    success: function(result) {
      if(result.rows.length > 0){
        that.updateInfoWindow(result.rows[0], feature);
        that.updatePagination(feature, featureList);
        $('#content').show();
      }
    },
    error: function(e) {}
  });
}

CartoDBInfowindow.prototype.hide = function() {
  if (this.div_) {
    var div = this.div_;
    $(div).animate({
      top: '+=' + 10 + 'px',
      opacity: 0},
      100, 'swing',
      function () {
        div.style.visibility = "hidden";
      }
    );
  }
}

CartoDBInfowindow.prototype.show = function() {
  if (this.div_) {
    var div = this.div_;
    div.style.opacity = 0;
    div.style.visibility = "visible";
    $(div).animate({
      top: '-=' + 10 + 'px',
      opacity: 1},
      250
    );
  }
}

CartoDBInfowindow.prototype.isVisible = function(marker_id) {
  if (this.div_) {
    var div = this.div_;
    if (div.style.visibility == 'visible' && this.feature_!=null) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

CartoDBInfowindow.prototype._formatDate = function(date) {
  date = new Date(date);
  return date.getFullYear() + '-' + parseInt(date.getMonth()+1) + '-' + date.getDate() +
         ' ' + date.getUTCHours() + ':' + date.getUTCMinutes() + ':' + date.getUTCSeconds();
}