var GS = GS || {};
GS.forms = GS.forms || {};

// Updates the custom checkboxes, radio buttons, and pulldowns, based
// on the state of their hidden form fields
GS.forms.updateFormVisualElements = function() {
  // Set initial state of visual checkboxes based on if hidden fields
  // have initial value
  $('input.js-gs-checkbox-value:hidden').each(function() {
    var $this = $(this);
    if ($this.val() !== '') {
      var checkbox = $this.parent().find('.i-24-checkmark-off');
      checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
    }
  });
  // Set initial state of visual radio buttons based on if hidden fields
  // have initial value
  $('input.js-gs-radio-value:hidden').each(function() {
    var $this = $(this);
    if ($this.val() !== '') {
      $this.parent().find('.js-gs-radio').removeClass('active');
      checkbox = $this.parent().find('.js-gs-radio[data-gs-radio="' + $this.val() + '"]');
      checkbox.addClass('active');
    }
  });
  // For pulldowns, if any child elements are checked, then visually
  // checkmark the pulldown button
  var pulldowns = $('.js-pull-down.js-gs-checkbox');
  pulldowns.each(function() {
    var $parent = $(this).parent();
    if ($parent.find('input.js-gs-checkbox-value:hidden').filter(function() {
      return $(this).val() !== '';
    }).length > 0) {
      $(this).find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
    }
  });
};

$(function() {
    $('.js-gs-radio').on('click',function(){
        var self = $(this);
        var hidden_field = self.parent().siblings(".js-gs-radio-value");
        var gs_radio = self.data('gs-radio');
        hidden_field.val(gs_radio);
        self.siblings().removeClass('active');
        self.addClass('active');

    });

    $("body").on('click','.js-pull-down',function(){

        var self=$(this);
        var gs_pull_down = self.data('pull-down-content');
        var pull_down_layer = $(gs_pull_down);
        var pull_down_button = pull_down_layer.siblings('.js-pull-down');
        pull_down_layer.slideToggle();
        var is_pull_down_selected =false;
        pull_down_layer.find('.js-gs-checkbox-value').each(function(){
            if ($(this).val() != ''){
                 is_pull_down_selected = true ;
             }
         });
        if (is_pull_down_selected == true) {
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
        }else {
            pull_down_button.find('.js-icon').removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
        }

    });

    $("body").on('click','.js-gs-checkbox',function(){

        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-24-checkmark-off').addClass('i-24-checkmark-on');
            hidden_field.val(gs_checkBox);

        }else {
            checkbox.removeClass('i-24-checkmark-on').addClass('i-24-checkmark-off');
            hidden_field.val('');
        }

    });
    $('.js-gs-checkbox-search').on('click',function(){
        var self=$(this);
        var checkbox = self.children(".js-icon");
        var hidden_field = self.siblings(".js-gs-checkbox-value");
        var gs_checkBox= self.data('gs-checkbox-value');
        var gs_checkBoxCategory= self.data('gs-checkbox-name');
        if (hidden_field.val()== '') {
            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
            hidden_field.attr("value", gs_checkBox).attr("name", gs_checkBoxCategory);
        } else {
            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
            hidden_field.removeAttr("value").removeAttr("name");
        }
    });

    $('.js-gs-checkbox-search-dropdown').on('click',function(){
       var self=$(this);
       var checkbox = self.children(".js-icon");
       var hidden_box = self.siblings(".js-gs-checkbox-search-collapsible-box");
       var children = hidden_box.children('div').children('.js-gs-checkbox-value');

       hidden_box.css('display') == 'none' ? hidden_box.show('slow') : hidden_box.hide('fast');
       toggleCheckboxForCollapsibleBox(checkbox, children);
    });

    var toggleCheckboxForCollapsibleBox = function(checkbox, children) {
        if (childCheckboxesAreEmpty(children)) {
            checkbox.removeClass('i-16-blue-check-box').addClass('i-grey-unchecked-box');
        } else {
            checkbox.removeClass('i-grey-unchecked-box').addClass('i-16-blue-check-box');
        }
    };

    var childCheckboxesAreEmpty = function(children) {
        var isEmpty = true;
        $(children).each(function(i) {
            if ($(this).val() !== '') { isEmpty = false }
        });
        return isEmpty
    };

//    ToDo Refactor and combine collapsible box toggling functionality
    var toggleCheckboxForCollapsibleBoxOnLoad = function() {
        $('.js-gs-checkbox-search-dropdown').each(function(i) {
            var self=$(this);
            var checkbox = self.children(".js-icon");
            var hidden_box = self.siblings(".js-gs-checkbox-search-collapsible-box");
            var children = hidden_box.children('div').children('.js-gs-checkbox-value');
            toggleCheckboxForCollapsibleBox(checkbox, children);
        });
    };

    $('.js-guidedSearch').on('submit',function() {
        GS.search.schoolSearchForm.findByNameSelector = '#js-guidedQueryString';
        GS.search.schoolSearchForm.findByLocationSelector = '#js-guidedQueryString';
        try {
            if (GS.search.schoolSearchForm.isAddress(GS.search.schoolSearchForm.getSearchQuery())) {
                return GS.search.schoolSearchForm.submitByLocationSearch.call(this, guidedGeocodeCallbackFn);
            } else {
                return GS.search.schoolSearchForm.submitByNameSearch.call(this, getSelectedFilterValues());
            }
        } catch (e) {
            console.log(e);
            return false;
        }
    });

    var addToArray = function(hash, key, value) {
        if (hash[key] === undefined) {
            hash[key] = [value];
        } else {
            hash[key].push(value);
        }
    };

    var getSelectedFilterValues = function() {
        // Add input names here to opt them out of form serialization
        var EXCLUDE_THESE_INPUTS = ['location', 'distance'];
        var searchOptions = {};
        // values for inputs are iterated here
        $('.js-guidedSearch').find("input").each(function () {
            var $this = $(this);
            var name = $this.attr('name');
            if ($.trim($this.val()) > '' && name !== undefined && !EXCLUDE_THESE_INPUTS.contains(name)) {
                if (name.indexOf('[]') > -1) {
                    addToArray(searchOptions, name, $this.val());
                } else {
                    searchOptions[name] = $this.val();
                }
            }
        });
        searchOptions.state = 'DE';
        return searchOptions;
    };

    var guidedGeocodeCallbackFn = function(geocodeResult) {
        var searchOptions = getSelectedFilterValues();
        searchOptions = jQuery.extend(searchOptions, geocodeResult);
        searchOptions['locationSearchString'] = GS.search.schoolSearchForm.getSearchQuery();
        // pull values from any selects here
        searchOptions['distance'] = $('#js-guided-distance').val() || 5;
        searchOptions['grades'] = $('#js-guided-grades').val();

        // Not setting a timeout breaks back button
        setTimeout(function() { window.location.href = window.location.protocol + '//' + window.location.host +
            '/search/search.page' +
            GS.uri.Uri.getQueryStringFromObject(searchOptions); }, 1);
    };

    GS.forms.toggleCheckboxForCollapsibleBoxOnLoad = toggleCheckboxForCollapsibleBoxOnLoad;
});

$(document).ready(function() {
    GS.forms.toggleCheckboxForCollapsibleBoxOnLoad();
});
