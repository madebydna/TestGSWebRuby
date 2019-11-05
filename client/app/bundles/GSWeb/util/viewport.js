import { throttle, debounce, castArray, compact } from 'lodash';
import invariant from 'fbjs/lib/invariant';

export const XS = 0;
export const SM = 1;
export const MD = 2;
export const LG = 3;

export const validSizes = [XS, SM, MD, LG];

// inner box of window scroll area, relative to document
export const viewportBox = () => {
  const top =
    typeof window.pageYOffset === 'undefined'
      ? (document.scrollingElement || document.documentElement).scrollTop
      : window.pageYOffset;
  const bottom = top + window.innerHeight;
  const middle = top + (window.innerHeight / 2);
  const left =
    typeof window.pageXOffset === 'undefined'
      ? (document.scrollingElement || document.documentElement).scrollLeft
      : window.pageXOffset;
  const right = window.innerWidth;
  return {
    top,
    middle,
    bottom,
    left,
    right,
    height: bottom - top,
    width: right - left
  };
};

// calculate outer box relative to document
export const boxInDoc = el => {
  invariant(el, 'Cannot get bounding rectangle for missing element');
  const rect = el.getBoundingClientRect();
  const top = rect.top + viewportBox().top;
  const bottom = top + rect.height;
  const left = rect.left + viewportBox().left;
  const right = left + rect.width;

  return {
    top,
    bottom,
    left,
    right,
    height: bottom - top,
    width: right - left
  };
};

export const documentBox = () =>
  boxInDoc(window.document.querySelector('html'));

export const distanceTo = (box, otherBox) => ({
  top: box.top - otherBox.top,
  bottom: box.bottom - otherBox.bottom,
  left: box.left - otherBox.left,
  right: box.right - otherBox.right
});

export const intersection = (box, otherBox) => {
  const top = Math.max(box.top, otherBox.top);
  const bottom = Math.min(box.bottom, otherBox.bottom);
  const left = Math.max(box.left, otherBox.left);
  const right = Math.min(box.right, otherBox.right);
  if (bottom >= top && right >= left) {
    return {
      top,
      bottom,
      left,
      right
    };
  }
  return null;
};

const boxEquals = (box, otherBox) =>
  !!box && !!otherBox &&
  box.top === otherBox.top &&
  box.bottom === otherBox.bottom &&
  box.left === otherBox.left &&
  box.right === otherBox.right;

const boxContains = (box, otherBox) =>
  boxEquals(intersection(box, otherBox), otherBox);

export const isIntersection = (box, otherBox) => !!intersection(box, otherBox);

export const amountElementTopAboveViewport = el =>
  distanceTo(viewportBox(), boxInDoc(el)).top;

export const amountElementBottomBelowViewport = el =>
  -1 * distanceTo(viewportBox(), boxInDoc(el)).bottom;

export const elementInViewport = el =>
  isIntersection(boxInDoc(el), viewportBox());

export const elementEntirelyInViewport = el => {
  return boxContains(viewportBox(), boxInDoc(el));
}

export const maxTopVsViewport = el =>
  Math.max(boxInDoc(el).top, viewportBox().top);

export const minBottomVsViewport = el =>
  Math.min(boxInDoc(el).bottom, viewportBox().bottom);

export function viewport() {
  let e = window,
    a = 'inner';
  if (!('innerWidth' in window)) {
    a = 'client';
    e = document.documentElement || document.body;
  }
  return { width: e[`${a}Width`], height: e[`${a}Height`] };
}

export const relativeToViewport = el => distanceTo(boxInDoc(el), viewportBox());

export const relativeToViewportTop = el => {
  invariant(el, 'Cannot get bounding rectangle for missing element');
  const viewportRect = viewportBox();
  const elementBox = boxInDoc(el);

  const top = elementBox.top - viewportRect.top;
  const bottom = elementBox.bottom - viewportRect.top;
  const left = elementBox.left - viewportRect.left;
  const right = elementBox.right - viewportRect.left;
  const height = bottom - top;
  const width = right - left;
  return {
    top, bottom, left, right, height, width
  }
};

export function size() {
  const width = viewport().width;
  if (width < 768) {
    return XS;
  } else if (width < 992) {
    return SM;
  } else if (width < 1200) {
    return MD;
  }
  return LG;
}

export const ratioScrolledDown = () => viewportBox().middle / documentBox().height;

export const firstInViewport = els => els.find(el => elementEntirelyInViewport(el));

const onDomContentLoaded = callback => {
  if (window.document.readyState === "loading") {
    window.document.addEventListener("DOMContentLoaded", callback);
  } else {
    callback();
  }
}

export const isScrolledInViewport = (ele) => {
  const element = ele.getBoundingClientRect();
  const elemTop = element.top;
  const elemBottom = element.bottom - 200;

  const inView = elemTop < window.innerHeight && elemBottom >= 0;
  return inView;
}

export const isScrolledInViewportForAds = (ele) => {
  const boundingBox = ele.getBoundingClientRect();
  const topY = boundingBox.top;
  const bottomY = boundingBox.top + boundingBox.height;
  return topY >= 0 && bottomY <= Math.min(document.documentElement.clientHeight, window.innerHeight || 0);
}

// this is the 2nd implementation of this function, meant to be more generic than original one in search code
export function keepInViewport(
  selector,
  {
    initialTop = null,
    elementsAboveFunc = () => {},
    elementsBelowFunc = () => {},
    setTop = true,
    setBottom = true,
    shrink = false,
    hideIfNoSpace = false
  } = {}
) {
  let initialVisibility = null;

  const updateElementPosition = function updateElementPosition() {
    const target = window.document.querySelector(selector);
    const targetRelativeToViewport = relativeToViewportTop(target);
    const targetRelativeToDoc = boxInDoc(target);
    const elementsAbove = compact(castArray(elementsAboveFunc()));
    const elementsBelow = compact(castArray(elementsBelowFunc()));
    let newRelativeTop = null;

    if (!target) {
      return;
    }
    target.style.visibility = '';
    // save the target element's originally defined relative top and display property
    if (initialTop === null) {
      initialTop = targetRelativeToViewport.top;
    }
    if(initialVisibility === null) {
      initialVisibility = target.style.visibility;
    }
    let newVisibility = initialVisibility;

    if (setTop) {
      const minTop = elementsAbove.reduce(
        (max, e) => Math.max(max, relativeToViewportTop(e).bottom),
        0
      );
      newRelativeTop = Math.max(initialTop - viewportBox().top, minTop);
    }

    // fixed Math.min(minSoFar, e.offset().top) from e.position()
    // fixed height to be outerHeight
    // $offset().top is unreliable...doesnt include margins
    if (setBottom) {
      // there can be multiple items we want to keep below the target.
      // this finds the top of the highest one
      let bottom = elementsBelow.reduce(
        (minSoFar, e) => Math.min(minSoFar, boxInDoc(e).top),
        documentBox().height
      );
      if (shrink) {
        // if the target is able to be resized if needed, we can shorten it
        // so that it stays between the elements above and elements below as the page is scrolled
        bottom = Math.max(viewportBox().bottom - bottom, 0);
        target.style.bottom = `${bottom}px`;
      } else {
        // if we can't shrink the target, and the bottom of the target encounters the top
        // of elements we want to keep below, then we'll push the target up and out of the viewport
        let overlap = targetRelativeToDoc.bottom - bottom;
        if (newRelativeTop !== null) {
          overlap += newRelativeTop - targetRelativeToViewport.top;
        } 
        if (overlap > 0) {
          newRelativeTop -= overlap;
          if(hideIfNoSpace) {
            newVisibility = 'hidden';
          }
        }
      }
    }

    target.style.visibility = newVisibility;
    if (newRelativeTop !== null) {
      target.style.top = `${newRelativeTop}px`
    }
  };

  onDomContentLoaded(() => {
    window.addEventListener("scroll", throttle(updateElementPosition, 10));
    window.addEventListener("resize", throttle(updateElementPosition, 10));
  })

  updateElementPosition();
}