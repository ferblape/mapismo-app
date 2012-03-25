//= require jquery-ui
//= require jquery.timePicker.min.js
//= require draw_polygon
//= require cartodb
//= require new_map
//= require_self

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
        return '+' + time.getUTCHours() + ':' + time.getUTCMinutes() + ':' + time.getUTCSeconds();
      }
      return "";
    },

    _formatDayOrdinal: function(day){
      var ordinal = "th";
      if(day == 1) { ordinal = 'st' };
      if(day == 2) { ordinal = 'nd' };
      if(day == 3) { ordinal = 'rd' };
      return day+ordinal;
    },

    _formatDateShort: function(date){
      if(date != null) {
        return date.getShortMonthName() + ' ' + this._formatDayOrdinal(date.getDate());
      }
      return "";
    },

    _formatDateRange: function(from, to){
      if(from == null || to == null){
        return "";
      }
      console.log("%s - %s", from, to);
      var showYear = false;
      var showMonth = false;
      var showDay = false;
      if(from.getFullYear() != to.getFullYear()){
        showYear = true;
        showMonth = true;
      } else {
        if(from.getMonth() != to.getMonth()){
          showMonth = true;
          showDay = true;
        } else {
          if(from.getDate() != to.getDate()){
            showDay = true;
          }
        }
      }
      var result = this._formatDateShort(from);
      if(showYear) {
        result += " " + from.getFullYear();
      }
      if(showMonth || showDay) {
        result += ' - ';
      }
      if(showMonth){
        result += ' ' + this._formatDateShort(to);
      } else {
        if(showDay){
          result += ' ' + this._formatDayOrdinal(to.getDate());
        }
      }
      result += " " + to.getFullYear();
      return result;
    },

    parentElement: function(){
      return $('header#top_bar');
    },

    readyForSaving: function(){
      return false;
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
      this.enableGoButton();
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
      this.enableGoButton();
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
      this.enableGoButton();
    },

    setWhenValues: function(){
      $('#map_start_date').val(this._formatDateLong($('#from_day').datepicker('getDate'))+
                                this._formatTimeLong($.timePicker("#from_time").getTime()));
      $('#map_end_date').val(this._formatDateLong($('#to_day').datepicker('getDate'))+
                              this._formatTimeLong($.timePicker("#to_time").getTime()));
      this.enableGoButton();
    },

    enableGoButton: function(){
      $('.progress_bar, .save_bar').hide();
      if(($('#map_location_name').val().isBlank()) ||
      ($('.social_networks input:checkbox:checked').length == 0) || ($('#from_day').val().isBlank()) ||
      ($('#to_day').val().isBlank())){
        this.disableGoButton();
        return;
      }
      $('#top_bar a.button').attr('disabled', null).removeClass('disabled').html('Go');
    },

    disableGoButton: function(){
      $('#top_bar a.button').attr('disabled', 'disabled');
      $('#top_bar a.button').addClass('disabled');
    },

    showProgress: function(){
      $('#top_bar a').removeClass('selected');
      this.disableGoButton();
      $('.save_bar').hide();
      $('.progress_bar').show();
    },

    hideProgress: function(){
      $('.progress_bar').fadeOut('slow', function(){
        $('.save_bar').fadeIn('slow')
      });
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

      if(!$('input#map_keywords').val().isBlank()){
        parsedValue += " about ";
        // TODO: the last ',' should be 'and'
        parsedValue += $('input#map_keywords').val().split(",").join(", ");
      }

      // Where
      this.parentElement().find('a:eq(0)').html(parsedValue);
      this.parentElement().find('a:eq(1)').html($('input#map_location_name').val());
      // When
      this.parentElement().find('a:eq(2)').html(this._formatDateRange($('#from_day').datepicker('getDate'), $('#to_day').datepicker('getDate')));

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
      this.whatValues(['flickr'], ['fallas']);
      this.whereValue('Valencia');
    },
    map: null,
    geocoder: null,

    initDOM: function(carto_embed_map){
      var that = this;

      $('.popover').hide();
      $('.popover.what').show();

      // radius slider
      $('#radius-picker').slider({
        range: 'min',
        min: 50,
        max: 5000,
        step: 50,
        value: $('#map_radius').val(),
        slide: function(event, ui){
          $('#radius').html(ui.value + " meters");
          that.enableGoButton();
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

      var toDate = new Date("2012-03-20");
      var fromDate = new Date("2012-03-01");
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
          $('#content').hide();
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
          $('#content').hide();
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
          $('#content').hide();
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
          that.enableGoButton();
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
          if($(this).is(':disabled')){
            return false;
          }
          if($(this).parents('form').length > 0){
            $(this).parents('form').submit();
          }
          e.preventDefault(); e.stopPropagation();
        }
      });

      this.disableGoButton();
    }
  });
}

var MAPISMO = {
  newMap: newMap()
};