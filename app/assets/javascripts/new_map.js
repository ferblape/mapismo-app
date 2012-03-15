Date.prototype.monthNames = [
    "January", "February", "March",
    "April", "May", "June",
    "July", "August", "September",
    "October", "November", "December"
];

Date.prototype.getMonthName = function() {
    return this.monthNames[this.getMonth()];
};
Date.prototype.getShortMonthName = function () {
    return this.getMonthName().substr(0, 3);
};

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
    },
    
    addKeyword: function(keyword){
      keyword = keyword.trim();
      if(keyword == ""){
        return;
      }
      var val;
      if($('input#map_keywords').val().trim() == ""){
        val = [];
      } else {
        val = $('input#map_keywords').val().split(",");
      }
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

    setWhenValues: function(){
      $('#map_start_date').val(this._formatDateLong($('#from_day').datepicker('getDate'))+
                                this._formatTimeLong($.timePicker("#from_time").getTime()));
      $('#map_end_date').val(this._formatDateLong($('#to_day').datepicker('getDate'))+
                              this._formatTimeLong($.timePicker("#to_time").getTime()));
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
    },

    initMapValues: function(){
      this.geocoder = new google.maps.Geocoder();
      this.whatValues(['flickr','instagram'], ['football','15m']);
      this.whereValue('Madrid');
    },

    geocoder: null,

    initDOM: function(){
      var that = this;
      
      $('.popover').hide();
      $('.save_bar').hide();

      // radius slider
      $('#radius-picker').slider({
        range: 'min',
        min: 500,
        max: 5000,
        step: 500,
        value: $('#map_radius').val(),
        change: function(e, ui){
          $('#map_radius').val(ui.value);
        }
      });
      
      // Date pickers
      $('#from_day').datepicker({
        dateFormat: 'yy-mm-dd',
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
            $('.popover.where').fadeOut('slow');
          }
        }
      });

      this.parentElement().find('a[data-type=what]').on({
        click: function(e){
          $('.popover').hide();
          $('.popover.what').show();
          $('#new_keyword').focus();
          e.preventDefault(); e.stopPropagation();
        }
      });

      this.parentElement().find('a[data-type=where]').on({
        click: function(e){
          $('.popover').hide();
          $('.popover.where').show();
          $('#map_location_name').focus();
          e.preventDefault(); e.stopPropagation();
        }
      });
      
      this.parentElement().find('a[data-type=when]').on({
        click: function(e){
          $('.popover').hide();
          $('.popover.when').show();
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
      
      $('a.button').on({
        click: function(e){
          if($(this).parents('form').length > 0){
            $(this).parents('form').submit();
          }
        }
      })
    }
  });
}

var MAPISMO = {
  newMap: newMap()
};