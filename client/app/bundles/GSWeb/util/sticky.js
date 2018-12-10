import { throttle, debounce } from 'lodash';
import $ from 'jquery';

export const keepInViewport = (
  ref,
  {
    initialTop = null,
    $elementsAbove = [],
    $elementsBelow = [],
    setTop = true,
    setBottom = true,
    shrink = false
  } = {}
) => {
  if (initialTop === null && $(ref.current).size > 0) {
    initialTop = $(ref.current).position().top;
  }

  const updateElementPosition = function updateElementPosition() {
    const $elem = $(ref.current);
    if ($elem.size === 0 || !$elem.position()) {
      return;
    }
    if (initialTop === null) {
      initialTop = $elem.position().top;
    }
    let top = null;
    if (setTop) {
      const YValueOfTopOfViewport = $(window).scrollTop();
      const minTop = $elementsAbove.reduce(
          (sum, $e) => sum + $e.outerHeight(),
        0
    );
      top = Math.max(initialTop - YValueOfTopOfViewport, minTop);
    }

    if (setBottom) {
      const YValueOfBottomOfViewport =
        $(window).scrollTop() + $(window).height();
      const minBottomY = $elementsBelow.reduce(
          (minSoFar, e) => Math.min(minSoFar, e.position().top),
        $('html').height()
    );
      if (shrink) {
        const bottom = Math.max(YValueOfBottomOfViewport - minBottomY, 0);
        $elem.css({ bottom: `${bottom}px` });
      } else {
        let overlap = $elem.offset().top + $elem.height() - minBottomY;
        if (top !== null) {
          overlap += top - $elem.position().top;
        }
        if (overlap > 0) {
          top -= overlap;
        }
      }
    }

    if (top !== null) {
      $elem.css({ top: `${top}px` });
    }
  };
  $(() => {
    $(window).on('scroll', throttle(updateElementPosition, 40));
  $(window).on('resize', debounce(updateElementPosition, 80));
});
  updateElementPosition();
}