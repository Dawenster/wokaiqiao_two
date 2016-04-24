var app = angular.module('wokaiqiao');

app.controller('CallListCtrl', ['$scope', function($scope) {
  overrideAnchorBehaviour()

  function overrideAnchorBehaviour() {
    if (location.hash) {
      var dest = 0;
      var listItem = $(location.hash);
      if (listItem.offset().top > $(document).height() - $(window).height()) {
        dest = $(document).height() - $(window).height();
      } else {
        dest = listItem.offset().top;
      }
      $('html,body').animate({
        scrollTop: dest - 220
      }, 1000, 'swing');
    }
  }

  $(document).ready(function() {
    var tab = getQueryVariable("t")
    if (tab) {
      var tabElement = $("#" + tab)
      $('#calls-tabs').foundation('selectTab', tabElement);
    }

    var openRatingId = getQueryVariable("openRating")
    if (openRatingId) {
      $("#rateCallModal" + openRatingId).foundation('open');
    }
  })

  function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
      var pair = vars[i].split('=');
      if (decodeURIComponent(pair[0]) == variable) {
        return decodeURIComponent(pair[1]);
      }
    }
    return null
  }
}]);
