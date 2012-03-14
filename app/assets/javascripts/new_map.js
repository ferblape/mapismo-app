function newMap(){
  return({
    parentElement: function(){
      return $('header#top_bar');
    },
    
    whatPosition: function(){
      var left = this.parentElement().find('a:eq(0)').position().left;
      var width = this.parentElement().find('a:eq(0)').width() / 2;
      $('.popover.what').css('left', left + width - $('.popover.what').width()/2);
    },

    wherePosition: function(){
      var left = this.parentElement().find('a:eq(1)').position().left;
      var width = this.parentElement().find('a:eq(1)').width() / 2;
      $('.popover.where').css('left', left + width - $('.popover.where').width()/2);
    },

    whenPosition: function(){
      var left = this.parentElement().find('a:eq(2)').position().left;
      var width = this.parentElement().find('a:eq(2)').width() / 2;
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
    },
    
    addKeyword: function(keyword){
      keyword = keyword.trim();
      if(keyword == ""){
        return;
      }
      var val = $('input#map_keywords').val().split(",");
      val.push(keyword)
      $('input#map_keywords').val(val.join(","));
      this.updateKeywordList();
      this.updateMapBar();
    },
    
    whatValues: function(sources, keywords){
      sources.forEach(function(source){
        var str;
        switch(source) {
          case "flickr":
            $('.popover.what input[value=flickr]').attr('checked','checked');
            break;
          case "instagram":
            $('.popover.what input[value=instagram]').attr('checked','checked');
            break;
        };
      });
      $('input#map_keywords').val(keywords.join(","));
      this.updateKeywordList();
    },

    whereValue: function(value){
      $('input#map_location_name').val(value);
      this.geocoder.geocode({'address': value}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          var latlng = results[0].geometry.location;
          $('input#map_lat').val(latlng.lat());
          $('input#map_lon').val(latlng.lng());
        } else {
          $('input#map_lat').val(0.0);
          $('input#map_lon').val(0.0);
        }
      });
      this.updateMapBar();
    },

    whenValues: function(fromDate, toDate){
      this.parentElement().find('a:eq(2)').html(fromDate);
    },
    
    updateMapBar: function(){
      var parsedValue = "";
      $('.popover.what input:checked').each(function(){
        switch($(this).val()){
          case "flickr":
            str = "Flickr photos";
            break;
          case "instagram":
            str = "Instagram photos";
            break;
        }
        (parsedValue == "") ? parsedValue += str : parsedValue += " and " + str;
      });
      parsedValue += " about ";
      // TODO: the last ',' should be 'and'
      parsedValue += $('input#map_keywords').val().split(",").join(", ");
      
      this.parentElement().find('a:eq(0)').html(parsedValue);
      this.parentElement().find('a:eq(1)').html($('input#map_location_name').val());
    },
    
    initMapValues: function(){
      this.geocoder = new google.maps.Geocoder();
      this.whatValues(['flickr','instagram'], ['football','15m']);
      this.whereValue('Madrid');
      this.whenValues('13th October');
    },
    
    geocoder: null,
    
    initDOM: function(){
      var that = this;
      
      $('.popover').hide();
      $('.save_bar').hide();
      this.whatPosition();
      this.wherePosition();
      this.whenPosition();
      
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
            $('.popover.where').fadeOut('slow');
          }
        }
      });
      
      this.parentElement().find('a[data-type=what]').on({
        click: function(e){
          $('.popover.what').toggle();
          $('#new_keyword').focus();
          e.preventDefault(); e.stopPropagation();
        }
      });
      
      this.parentElement().find('a[data-type=where]').on({
        click: function(e){
          $('.popover.where').toggle();
          $('#map_location_name').focus();
          e.preventDefault(); e.stopPropagation();
        }
      });

      $('.popover.what input').on({
        change: function(e){
          that.updateMapBar();
          e.preventDefault(); e.stopPropagation();
        }
      });
      
      $('ul#keywords_list').on('click', 'a.delete', function(e){
        var parent = $(this).parents('li');
        that.removeKeyword(parent.text().replace("Remove", ""));
        parent.remove();
        e.preventDefault(); e.stopPropagation();
      });
    }
  });
}

var MAPISMO = {
  newMap: newMap()
};

