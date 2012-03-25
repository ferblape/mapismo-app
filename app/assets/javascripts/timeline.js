function Timeline(){
  this.features = [];
  this.featurePositionsInPx = {};
}

Timeline.prototype.initDOM = function(){
  var that = this;
  $('#timeline_bar').on('click', 'a.play', function(e){
    that.start();
    e.preventDefault; e.stopPropagation();
  });
  $('#timeline_bar').on('click', 'a.pause', function(e){
    that.pause();
    e.preventDefault; e.stopPropagation();
  });

  // handle keyboard strokes
  $(document).keyup(function(e) {
    // space bar
    if(e.keyCode == 32) {
      that.playOrPause();
      e.preventDefault(); e.stopPropagation();
    }
  });
}

Timeline.prototype.setupFeatures = function(features,infowindow,featureList){
  this.infowindow = infowindow;
  this.featureList = featureList;
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
  $('#timeline_bar a.button').removeClass('play').addClass('pause').html('Pause');

  this.state = "playing";
  var that = this;
  this.timer = setInterval(function(){
    var newPosition = parseInt($('#pointer').css('left'))+1;
    $('#pointer').css('left', newPosition + 'px');
    if(newPosition >= $('#timeline').width() - $('#pointer').width()){
      clearInterval(that.timer);
    }
    that.triggerClick(newPosition);
  }, 300);
};

Timeline.prototype.pause = function(){
  $('#timeline_bar a.button').addClass('play').removeClass('pause').html('Play');
  this.state = "paused;"
  clearInterval(this.timer);
};

Timeline.prototype.playOrPause = function(){
  if(this.state == "playing"){
    this.pause();
  } else {
    this.start();
  }
};

Timeline.prototype.setPointer = function(position){
  $('#pointer').css('left', position + 'px');
  this.triggerClick(position);
};

Timeline.prototype.triggerClick = function(position){
  var featureId = this.featurePositionsInPx[(position).toString()];
  if(featureId != null){
    this.infowindow.open(featureId,null,this.featureList);
    $('#timeline ul.items li').removeClass('selected');
    $('#timeline ul.items li[data-id='+featureId+']').addClass('selected');
  }
};

