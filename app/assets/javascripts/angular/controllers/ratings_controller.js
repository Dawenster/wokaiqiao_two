var app = angular.module('wokaiqiao');

app.controller('RatingsCtrl', ['$scope', '$element', function($scope, $element) {

  $(".raty-div").raty({
    score: $element.data("rating"),
    readOnly: true,
    noRatedMsg: "还没有评分"
  });

  $(".blank-user-raty-div").raty({
    scoreName: "call[user_rating]",
    score: $element.find(".blank-user-raty-div").data("user-rating")
  });

  $(".blank-expert-raty-div").raty({
    scoreName: "call[expert_rating]",
    score: $element.find(".blank-expert-raty-div").data("expert-rating")
  });

  $("body").on("click", ".leave-rating-button", function(e) {
    e.preventDefault()
    $(".alert-text").addClass("hide")

    var userRating = $element.find(".blank-user-raty-div input").val()
    var expertRating = $element.find(".blank-expert-raty-div input").val()

    if (!userRating && !expertRating) {
      $(".alert-text").removeClass("hide")
    } else {
      $element.find("form").submit()
    }
  })

}]);
