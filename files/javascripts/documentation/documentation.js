hljs.initHighlightingOnLoad();

$(document).ready(function() {
  $('.result').hide().parent().addClass('hidden');
  $(window).keypress(function (e) {
    var c = String.fromCharCode(e.which);
    if (c == 'h' || c == 'H') {
      $('.result').slideUp().parent().addClass('hidden')
    } else if (c == 'v' || c =='V') {
      $('.result').slideDown().parent().removeClass('hidden')
    }
  });
  $("pre.hidden").live("click", function(event) {
    target = $(event.target)
    target.contents().slideDown().parent().removeClass('hidden')
  });
  $(".page-title").after('<ul id="toc"></ul>')
  $("#toc").tableOfContents();

});