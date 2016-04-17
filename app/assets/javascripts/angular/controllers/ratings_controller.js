var app = angular.module('wokaiqiao');

app.controller('RatingsCtrl', ['$scope', '$element', function($scope, $element) {

  $(".raty-div").raty({
    score: $element.data("rating"),
    readOnly: true,
    noRatedMsg: "还没有评分"
  });

  $(".blank-user-raty-div").raty({
    scoreName: "call[user_rating]",
    score: $element.data("user-rating")
  });

  $(".blank-expert-raty-div").raty({
    scoreName: "call[expert_rating]",
    score: $element.data("expert-rating")
  });

}]);
