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
    },

    whereValue: function(value){
      this.parentElement().find('a:eq(1)').html(value);
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
      
      this.parentElement().find('a:eq(0)').html(parsedValue);
    },
    
    initMapValues: function(){
      this.whatValues(['flickr','instagram'], ['football','15m']);
      this.whereValue('Madrid');
      this.whenValues('13th October');
      this.updateMapBar();
    },
    
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
        if (e.keyCode == 27) {
          $('.popover').hide();
          e.preventDefault(); e.stopPropagation();
        }
      });
      
      this.parentElement().find('a').on({
        click: function(e){
          $('.popover.' + $(this).data('type')).toggle();
          e.preventDefault(); e.stopPropagation();
        }
      });

      $('.popover.what input').on({
        change: function(e){
          that.updateMapBar();
          e.preventDefault(); e.stopPropagation();
        }
      })
    }
  });
}

var MAPISMO = {
  newMap: newMap()
};

