var app = angular.module('wokaiqiao');

app.controller('BookExpertCtrl', ['$scope', function($scope) {
  var datepickers = $(".datepicker")
  var internationalization = {
    previousMonth : '上个月',
    nextMonth     : '下个月',
    months        : ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'],
    weekdays      : ['星期天','星期一','星期二','星期三','星期四','星期五','星期六'],
    weekdaysShort : ['日','一','二','三','四','五','六']
  }
  for (var i = 0; i < datepickers.length; i++) {
    var picker = new Pikaday({
      field: datepickers[i],
      disableDayFn: function(date){
        var today = new Date()
        var yesterday = today.setDate(today.getDate() - 1);
        return date <= yesterday;
      },
      i18n: internationalization
    });
  };
}]);
