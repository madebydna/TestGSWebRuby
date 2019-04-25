import ReactOnRails from 'react-on-rails';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';
import { indexOf } from 'lodash';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  SearchBoxWrapper,
});

$(commonPageInit);

$(function () {

  $('input:checkbox').on('click', function() {
    let $this = $(this);
    let value = $this.prop('checked');
    let name = $this.attr('name');

    let newLocation = location.href.replace(new RegExp("&?" + name + "=([^&]$|[^&]*)", "i"), "");

    if (indexOf(newLocation, '?') === -1) {
      newLocation += '?';
    } else {
      newLocation += '&';
    }
    location.href = newLocation + name + "=" + value;
  });

  let filterByTopicButton = (function() {
    function EventHandler($element) {
      this.selectTopicCallback = null;
      let self = this;

      $element.on("click", "a", function(){
        let selectedTopic = $(this).data("topic-filter");
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

    let init = function($element) {
      return new EventHandler($element);
    };

    return {
      init: init
    };
  })();

  let replaceParamAndReloadPage = function(name, value) {
    let newLocation = location.href.replace(new RegExp("&?" + name + "=([^&]$|[^&]*)", "i"), "");
    if (newLocation.charAt(newLocation.length-1) === '?') {
      newLocation = newLocation.substring(0, newLocation.length-1);
    }

    if (value !== undefined) {
      if (indexOf(newLocation, '?') === -1) {
        newLocation += '?';
      } else {
        newLocation += '&';
      }

      newLocation = newLocation + name + "=" + value;
    }

    window.location = newLocation;
  };

  let filterByTopic = function(topic) {
    replaceParamAndReloadPage('topic', topic);
  };


  filterByTopicButton.init($('.js_reviewTopicFilterDropDown')).onSelectTopic(function(topic) {
    filterByTopic(topic);
  });

  $("#new_banned_ip input[name='disable_ip']").on('click', function() {
    return confirm("Are you sure you want to block this IP from submitting reviews?");
  });
});
