function Timeline(){
  this.features = [];
  this.featurePositionsInPx = {};
}

Timeline.prototype.initDOM = function(){
  var that = this;
  $('#timeline_bar').on('click', 'a.play', function(e){
    that.start();
    $(this).removeClass('play').addClass('pause').html('Pause');
    e.preventDefault; e.stopPropagation();
  });
  $('#timeline_bar').on('click', 'a.pause', function(e){
    that.pause();
    $(this).addClass('play').removeClass('pause').html('Play');
    e.preventDefault; e.stopPropagation();
  });
}

Timeline.prototype.setupFeatures = function(features,infowindow,featureList){
  this.infowindow = infowindow;
  this.featureList = featureList;
  console.log(this.infowindow);
  this.features = features;
  var that = this;
  var minDate = features[0].date,
      maxDate = features[features.length - 1].date,
      reference = minDate - maxDate,
      list = $('#timeline ul.items'),
      width = $('#timeline').width(),
      li, percentage;

  features.forEach(function(feature){
    li = $('<li/>');
    percentage = ((minDate - feature.date)*100)/reference;
    li.css('left', percentage+'%').attr('data-date', feature.date).
    attr('data-id',feature.id).appendTo(list);
    that.featurePositionsInPx[(parseInt(percentage*width*0.01)).toString()] = feature.id;
  });

  li = $('<li/>');
  li.attr('id', 'pointer').css('left','0%').appendTo(list);

  this.initDOM();
};

Timeline.prototype.start = function(){
  this.state = "playing";
  var that = this;
  this.timer = setInterval(function(){
    var newPosition = parseInt($('#pointer').css('left'))+1;
    $('#pointer').css('left', newPosition + 'px');
    if(newPosition >= $('#timeline').width() - $('#pointer').width()){
      clearInterval(that.timer);
    }
    var featureId = that.featurePositionsInPx[(newPosition).toString()];
    if(featureId != null){
      that.infowindow.open(featureId,null,that.featureList);
      $('#timeline ul.items li').removeClass('selected');
      $('#timeline ul.items li[data-id='+featureId+']').addClass('selected');
    }
  }, 300);
};

Timeline.prototype.pause = function(){
  this.state = "paused;"
  clearInterval(this.timer);
};


