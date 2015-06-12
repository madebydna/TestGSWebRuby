if(gon.pagename == "admin_school_moderate"){
  GS = GS || {};
  GS.reviews = GS.reviews || {};
  GS.admin = GS.admin || {};
  GS.admin.schools = GS.admin.schools || {};

  GS.reviews.filterByTopicButton = (function() {
    function EventHandler($element) {
      this.selectTopicCallback = null;
      var self = this;

      $element.on("click", "a", function(){
        var selectedTopic = $(this).data("topic-filter");
        if (selectedTopic == 'allTopics') {
          selectedTopic = undefined;
        }
        self.selectTopicCallback(selectedTopic);
      });

      this.onSelectTopic = function(callback) {
        self.selectTopicCallback = callback;
      };

      return self;
    }

    var init = function($element) {
      return new EventHandler($element);
    };

    return {
      init: init
    };
  })();

  GS.admin.schools.moderate = (function() {
    var replaceParamAndReloadPage = function(name, value) {
      newLocation = location.href.replace(new RegExp("&?" + name + "=([^&]$|[^&]*)", "i"), "");
      if (newLocation.charAt(newLocation.length-1) == '?') {
        newLocation = newLocation.substring(0, newLocation.length-1);
      }

      if (value != undefined) {
        if (_.indexOf(newLocation, '?') == -1) {
          newLocation += '?';
        } else {
          newLocation += '&';
        }

        newLocation = newLocation + name + "=" + value;
      }

      window.location = newLocation;
    };

    var filterByTopic = function(topic) {
      replaceParamAndReloadPage('topic', topic);
    };

    return {
      filterByTopic: filterByTopic
    }
  })();

  $(function() {
    GS.reviews.filterByTopicButton.init($('.js_reviewTopicFilterDropDown')).onSelectTopic(function(topic) {
      GS.admin.schools.moderate.filterByTopic(topic);
    });
  });

}