//ToDo is it ok to add this conditional to prevent js from executing on every page?
GS.compareSchools = GS.compareSchools || function () {
    var comparedSchools = '.js-comparedSchool';
    var comparedSchoolsList = '.js-comparedSchoolsList';
    var removeComparedSchool = '.js-removeComparedSchool';
    var activeLinkStyle = 'gs-active-link';
    var activeXCircle = 'i-16-active-x-circle';
    var blueXCircle = 'i-16-blue-x-circle';
    var carouselContainer = '.js-comparedSchoolsListContainer';
    var carouselNavigation = '.js-compareSchoolsCarouselNavigation';
    var prevSchoolButton = '.js-compareSchoolsPrev';
    var nextSchoolButton = '.js-compareSchoolsNext';
    var numberOfSchools = $(comparedSchools).length || 1;
    var clickOrTouchType = GS.util.clickOrTouchType || 'click';
    var schoolWidth = 300;
    var currentSchool = 0; //school that is currently on the left most slot of the carousel. max values are 0-3
    var carouselSpeed = 500;

    var adjustHeights = function (className) {
        var maxHeight = 0;
        $(className).each(function () {
            if ($(this).height() > maxHeight) {
                maxHeight = $(this).height();
            }
        });
        $(className).each(function () {
            $(this).height(maxHeight)
        })
    };

    var adjustSchoolResultsHeights = function () {
        adjustHeights('.js-schoolName');
        adjustHeights('.js-gradeLevel');
        adjustHeights('.js-comparePieChartTable');
        adjustHeights('.js-reviewSnapshot');
        adjustHeights('.js-reviewStars');
    };

    var setAccordianHandlerForCategories = function() {
        $(comparedSchoolsList).on('click', '.js-categoryTitle', function() {
            var $categoryData = $(this).siblings('.js-categoryData');
            var categoryDataClass = '.' + $categoryData.attr('class').split(/\s+/)[0];
            $(categoryDataClass).each(function() {
                  $(this).slideToggle('slow');
            });
        });
    };

    var setCarouselHandler = function() {
        setupCarousel();

        $(window).resize(function() {
            destroyCarousel();
            setupCarousel();
        });
    };

    var setupCarousel = function() {
        var windowWidth = $(window).width();

        if (windowWidth < 1200) {
            //reset carousel to first school, so on resize there won't be blank spaces after last school
            currentSchool = 0;
            scrollSchools(0, 0);
            numberOfSchools = $(comparedSchools).length || numberOfSchools;
            var minWidthNeededToDisplayAll = numberOfSchools * schoolWidth;

            if (windowWidth < minWidthNeededToDisplayAll) {
                var numberOfSchoolsToShow = Math.floor(windowWidth / schoolWidth);
                initCarousel(schoolWidth, numberOfSchoolsToShow);
                showNextPrevNavigation();
            } else {
                hideNextPrevNavigation();
            }
        }
    };

    var initCarousel = function(schoolWidth, numberOfSchoolsToShow) {
        //set carousel container's width to how many max schools can fit on page
        $(carouselContainer).width(schoolWidth * numberOfSchoolsToShow);
        $(comparedSchoolsList).swipe({
            triggerOnTouchEnd: true,
            swipeStatus: swipeStatus,
            allowPageScroll: "vertical"
        });
    };

    var showNextPrevNavigation = function() {
        if (clickOrTouchType != 'touchstart') {
            $(carouselNavigation).each(function() {
                $(this).addClass('hidden-lg').removeClass('hidden')
            })
        }
    };

    var hideNextPrevNavigation = function() {
        $(carouselNavigation).each(function() {
            $(this).hide().removeClass('hidden-lg');
        })
    };

    var setNextPrevHandler = function() {
        $(prevSchoolButton).each(function() {
            $(this).on('click', function() {
                previousSchool();
            });
        });
        $(nextSchoolButton).each(function() {
            $(this).on('click', function() {
                nextSchool();
            })
        });
    };

    var destroyCarousel = function() {
        var $comparedSchoolsList = $(comparedSchoolsList);

        $(carouselContainer).css('width', '');
        if ($comparedSchoolsList.length != 0 ) {
            $comparedSchoolsList.swipe('destroy');
        }
    };

    var swipeStatus = function(event, phase, direction, distance, fingers) {
        //If we are moving before swipe, and we are going L or R, then manually drag the images
        if (phase == "move" && (direction == "left" || direction == "right")) {
           var duration = 0;

           if (direction == "left") {
               scrollSchools((schoolWidth * currentSchool) + distance, duration);
           } else if (direction == "right") {
               scrollSchools((schoolWidth * currentSchool) - distance, duration);
           }

        } else if (phase == "cancel") { //Else, cancel means snap back to the beginning
            scrollSchools(schoolWidth * currentSchool, carouselSpeed);

        } else if (phase == "end") { //Else end means the swipe was completed, so move to the next image
            if (direction == "right") {
                previousSchool();
            } else if (direction == "left") {
                nextSchool();
            }
        }
    };

    var previousSchool = function() {
        currentSchool = Math.max(currentSchool - 1, 0);
        scrollSchools(schoolWidth * currentSchool, carouselSpeed);
    };

    var nextSchool = function() {
        var numberOfSchoolsToShow = Math.floor($(window).width() / schoolWidth);
        currentSchool = Math.min(currentSchool + 1, numberOfSchools - numberOfSchoolsToShow);
        scrollSchools(schoolWidth * currentSchool, carouselSpeed);
    };

    var scrollSchools = function(distance, duration) {
        var $comparedSchoolsList = $(comparedSchoolsList);

        $comparedSchoolsList.css({transition: (duration / 1000).toFixed(1) + "s"});

        //Inverse the number we set in the css. To show the next schools we slide the carousel negatively and for natural movement positively
        var value = (distance < 0 ? "" : "-") + Math.abs(distance).toString();

        $comparedSchoolsList.css({transform: "translate(" + value + "px,0px)"});
    };

    var removeSchool = function() {
        var schoolDiv = $(this).parent('div'+comparedSchools);
        var schoolId = schoolDiv.data('school-id');
        $(schoolDiv).hide('slow', function(){
            $(schoolDiv).remove();
            destroyCarousel();
            setupCarousel();
            GS.search.googleMap.removeMapMarkerBySchoolId(schoolId);
        });
    };

    var setRemoveSchoolHandler = function () {
        $(comparedSchoolsList).on('click', removeComparedSchool, removeSchool);
    };

    var colorPieChartLabels = function() {
        var colors = GS.visualchart.colors;
        $('.js-comparePieChartTable').each( function() {
            $(this).children('tbody').children('tr').children('td').children('.js-comparePieChartSquare').each(function (index) {
                $(this).css({ background: colors[index] });
            });
        });
    };

    var setRemoveActiveStateHandler = function () {
        $(removeComparedSchool).hover(
            function () {
                $(this).addClass(activeLinkStyle);
                $(this).children('i').removeClass(blueXCircle).addClass(activeXCircle);
            },
            function () {
                $(this).removeClass(activeLinkStyle);
                $(this).children('i').addClass(blueXCircle).removeClass(activeXCircle);
            }
        );
    };

    var init = function() {
        adjustSchoolResultsHeights();
        setAccordianHandlerForCategories();
        setCarouselHandler();
        setNextPrevHandler();
        setRemoveSchoolHandler();
        colorPieChartLabels();
        setRemoveActiveStateHandler();
    };


    return {
        init: init
    };
}();

if (gon.pagename == "CompareSchoolsPage") {
    $(document).ready(function () {
        GS.compareSchools.init();
    });
}
