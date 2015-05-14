GS.search = GS.search || {};

GS.search.assignedSchools = GS.search.assignedSchools || (function() {
    var validLocationTypes = ['street_address', 'route', 'intersection', 'premise', 'subpremise'];
    var _shouldCalculateFit = undefined;

    var shouldGetAssignedSchools = function() {
        if (gon.pagename != 'SearchResultsPage') {
            return false;
        }

        var pageNumber = GS.uri.Uri.getFromQueryString('page');
        if (pageNumber && pageNumber != '1') {
            return false;
        }

        var grade = GS.uri.Uri.getFromQueryString("grades");
        if (grade == 'p' || grade == 'pk') {
            return false;
        }
        return true;
    };

    var isSearchSpecificEnough = function() {
        var locationType = GS.uri.Uri.getFromQueryString("locationType");
        if (locationType) {
            for (var x=0; x < validLocationTypes.length; x++) {
                if (locationType.indexOf(validLocationTypes[x]) > -1) {
                    return true
                }
            }
        }
        return false;
    };

    var getAssignedSchools = function(setAssignedSchoolCallbackFn) {
        setAssignedSchoolCallbackFn = setAssignedSchoolCallbackFn || setAssignedSchool;
        var lat = GS.uri.Uri.getFromQueryString("lat");
        var lon = GS.uri.Uri.getFromQueryString("lon");
        var grade = GS.uri.Uri.getFromQueryString("grades");
        if (!lat || !lon || !isSearchSpecificEnough()) {
            $('#js-assigned-school-not-valid').show('slow');
            return;
        }
        var data = {lat: lat, lon: lon};
        var validGradesMap = {
            'k': 'e', '1': 'e', '2': 'e', '3': 'e', '4': 'e', '5': 'e',
            '6': 'm', '7': 'm', '8': 'm',
            '9': 'h', '10': 'h', '11': 'h', '12': 'h'
        };
        if (grade && validGradesMap[grade]) {
            data.grade = grade;
        }
        jQuery.getJSON("/geo/boundary/ajax/getAssignedSchoolByLocation.json", data, function(data) {
            if (data && data.results && data.results.length) {
                var totalSchoolsFound = 0;
                for (var x=0; x < data.results.length; x++) {
                    var schoolWrapper = data.results[x];
                    if (schoolWrapper.schools && schoolWrapper.schools.length) {
                        totalSchoolsFound += schoolWrapper.schools.length;
                        try {
                            setAssignedSchoolCallbackFn(schoolWrapper.level, schoolWrapper.schools[0]);
                        } catch (e) {
                            // on any error just ignore it and move on
                        }
                    }
                }
                if (totalSchoolsFound == 0) {
                    setNoAssignedSchools();
                }
            } else if (data && data.results && data.results.length === 0) {
                setNoAssignedSchools();
            }
        });
    };

    var setAssignedSchool = function(levelCode, school) {
        if (school.id) {
            setAssignedSchoolInMap(levelCode, school.id);
            setAssignedSchoolInList(levelCode, school);
        }
    };

    var setAssignedSchoolInMap = function(levelCode, schoolId) {
        var level = 'elementary';
        if (levelCode == 'm') {
            level = 'middle';
        } else if (levelCode == 'h') {
            level = 'high';
        }
        GS.googleMap.setAssignedSchool(schoolId, level);
    };

    var setAssignedSchoolInList = function(levelCode, school) {
        var level = 'elementary';
        if (levelCode == 'm') {
            level = 'middle';
        } else if (levelCode == 'h') {
            level = 'high';
        }
        var listItemSelector = '#js-assigned-school-' + level;

        var $listItem = $(listItemSelector);

        var distance = Math.round(school.distance * 100) / 100;
        var gradeRange = school.gradeRange;
        var schoolId = school.id;
        var name = school.name;
        var numReviews = school.numReviews;
        var parentRating = school.parentRating;
        var gsRating = school.rating;
        var type = school.schoolType;
        var state = school.state;
        var zip = school.address.zip;
        if (type == 'public') {
            type = 'Public district';
        } else if (type == 'charter') {
            type = 'Public charter';
        } else {
            type = type.charAt(0).toUpperCase() + type.slice(1);
        }
        var url = school.url;
        var reviewsUrl = school.url + 'reviews/';
        var qualityUrl = school.url + 'quality/';
        var address = school.address.street1 + ', ' + school.address.cityStateZip;

        $listItem.find('.js-name').html(name).attr('href', url);
        $listItem.find('.js-address').html(address);
        $listItem.find('.js-type').html(type);
        $listItem.find('.js-grade-range').html(gradeRange);
        $listItem.find('.js-distance').html(distance + ' miles');
        if (parentRating && parentRating > 0 && parentRating < 6) {
            var orangeStar = $listItem.find('.js-parent-rating-stars .i-16-orange-star');
            var greyStar = $listItem.find('.js-parent-rating-stars .i-16-grey-star');
            orangeStar.removeClass('i-16-star-1').addClass('i-16-star-' + parentRating);
            greyStar.removeClass('i-16-star-4').addClass('i-16-star-' + (5-parentRating));
        } else {
            $listItem.find('.js-parent-rating-stars').hide();
        }
        if (numReviews) {
            var reviewWord = ' review';
            if (numReviews > 1) {
                reviewWord = ' reviews';
            }
            $listItem.find('.js-review-count').html(numReviews + reviewWord).attr('href', reviewsUrl);
            $listItem.find('.js-no-reviews').hide();
        } else {
            $listItem.find('.js-review-count').hide();
            $listItem.find('.js-no-reviews').show();
        }
        if (gsRating && gsRating > 0 && gsRating < 11) {
            var gsRatingLink = $listItem.find('.js-gs-rating-link');
            gsRatingLink.attr('href', qualityUrl).find('.iconx24-icons').removeClass('i-24-new-ratings-nr').addClass('i-24-new-ratings-' + gsRating);
        }

        var compareButton = $listItem.find('.js-compareSchoolButton');
        compareButton.attr('data-schoolid', schoolId);
        compareButton.attr('data-schoolstate', state);
        compareButton.attr('data-schoolname', name);
        if (gsRating && gsRating > 0 && gsRating < 11) {
            compareButton.attr('data-schoolrating', gsRating);
        }
        GS.search.results.toggleOnCompareSchools();

        $listItem.find('.js-homes-for-sale').attr({'href':'http://www.zillow.com/' + state + '-' + zip + '?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=schoolsearch', 'rel':'nofollow'});

        var $existingSearchResult = $('.js-schoolSearchResult[data-schoolId=' + schoolId + '][data-schoolState=' + state.toLowerCase() + ']');

        var $existingSchoolPhoto = $existingSearchResult.find('.js-schoolPhoto').children();
        if ($existingSchoolPhoto.size() > 0) {
            $listItem.find('.js-photo').html($existingSchoolPhoto.clone());
        }

        syncAttributesFromExistingResult($existingSearchResult, $listItem);

        //Todo maybe this block into syncAttributesFromExistingResult?
        if (shouldCalculateFit()) {
            var $existingFitScorePopup = $existingSearchResult.find('.js-schoolFitScore').children();
            if ($existingFitScorePopup.size() > 0) {
                $listItem.find('.js-fitScore').html($existingFitScorePopup.clone());
                GS.search.results.searchResultFitScoreTogglehandler($listItem);
                $listItem.show('slow');
            } else {
                jQuery.ajax({
                    type:'GET',
                    url:'/gsr/ajax/search/calculate_fit',
                    data:{
                        state: gon.state_abbr,
                        city: gon.city_name,
                        id: school.id
                    },
                    dataType:'text',
                    async:true
                }).done(function (html) {
                    $listItem.find('.js-fitScore').html(html);
                    GS.search.results.searchResultFitScoreTogglehandler($listItem);
                }).always(function () {
                    $listItem.show('slow');
                });
            }
        } else {
            $listItem.show('slow');
        }
    };

    var syncAttributesFromExistingResult = function($existingSearchResult, $listItem) {
        syncDistance($existingSearchResult, $listItem);
        syncReviewCount($existingSearchResult, $listItem);
    };

    var syncDistance = function($existingSearchResult, $listItem) {
        var $distance = $existingSearchResult.find('.js-distance');
        if ($distance.size() > 0) {
            var text = $distance.first().text();
            $listItem.find('.js-distance').html(text);
        }
    };

    var syncReviewCount = function($existingSearchResult, $listItem) {
        var $reviewCount = $existingSearchResult.find('.js-reviewCount');
        if ($reviewCount.size() > 0) {
            var text = $reviewCount.first().text();
            if (text === "No Community Reviews") {
                $listItem.find('.js-review-count').hide();
                $listItem.find('.js-no-reviews').show();
            } else {
                var href = $reviewCount.first().attr('href');
                $listItem.find('.js-review-count').html(text).attr('href', href);
                $listItem.find('.js-no-reviews').hide();
                $listItem.find('.js-review-count').show();
            }
        }
    };

    var shouldCalculateFit = function() {
        if (_shouldCalculateFit === undefined) {
            _shouldCalculateFit = $('.js-schoolFitScore').children().size() > 0;
        }
        return _shouldCalculateFit;
    };

    var setNoAssignedSchools = function() {
        $('#js-assigned-school-no-result').show('slow');
    };

    var init = function () {
        try {
            if (GS.search.assignedSchools.shouldGetAssignedSchools()) {
                GS.search.assignedSchools.getAssignedSchools();
            }
        } catch (e) {
            // ignore. This is prototype code
        }
    };

    return {
        init: init,
        shouldGetAssignedSchools:shouldGetAssignedSchools,
        getAssignedSchools: getAssignedSchools
    };
})();