var app = angular.module('wokaiqiao');

app.controller('RatingsCtrl', ['$scope', '$element', function($scope, $element) {

  if ($element.hasClass("readonly")) {
    var score = $element.data("rating")
    $element.raty({
      score: score,
      readOnly: true,
      noRatedMsg: "还没有评分"
    });
  }

  if ($element.hasClass("ratable")) {
    $element.find(".blank-user-raty-div").raty({
      scoreName: "call[user_rating]",
      score: $element.find(".blank-user-raty-div").data("user-rating")
    });

    $element.find(".blank-expert-raty-div").raty({
      scoreName: "call[expert_rating]",
      score: $element.find(".blank-expert-raty-div").data("expert-rating")
    });
  }

  $element.on("click", ".leave-rating-button", function(e) {
    e.preventDefault()
    $element.find(".alert-text").addClass("hide")

    var userRating = $element.find(".blank-user-raty-div input").val()
    var expertRating = $element.find(".blank-expert-raty-div input").val()

    if (!userRating && !expertRating) {
      $element.find(".alert-text").removeClass("hide")
    } else {
      $element.find("form").submit()
    }
  })

}]);
