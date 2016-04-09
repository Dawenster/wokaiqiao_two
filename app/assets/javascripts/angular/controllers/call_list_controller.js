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
}]);
