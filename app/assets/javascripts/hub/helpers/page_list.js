Handlebars.registerHelper('pageList', function (current, total, block) {
  var delta = 2,
    range = [],
    rangeWithDots = [],
    l,
    accum = '';

  range.push(1)  
  for (var i = current - delta; i <= current + delta; i++) {
    if (i < total && i > 1) {
      range.push(i);
    }
  }  
  range.push(total);
  //ES6 wont build on old uglify
  //for (var i of range) {
  for (var idx = 0; idx < range.length; ++idx) {
    var i = range[idx];
    
    if (l) {
      if (i - l === 2) {
          rangeWithDots.push(l + 1);
      } else if (i - l !== 1) {
          rangeWithDots.push('...');
      }
    }
    rangeWithDots.push(i);
    l = i;
  }

  $.each(rangeWithDots, function( index, value ) {
    accum += block.fn(value);
  });
  return accum;
});