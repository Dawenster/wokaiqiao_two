var app = angular.module('wokaiqiao');

app.controller('RatingsCtrl', ['$scope', '$element', function($scope, $element) {

  $(".raty-div").raty({
    // score: $element.data("rating"),
    score: 0,
    readOnly: true,
    noRatedMsg: "还没有评分"
  });

}]);
