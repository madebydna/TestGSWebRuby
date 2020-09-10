import { throttle } from 'lodash';
import { isScrolledInViewport } from 'util/viewport';

export const init = (element, classNames) => {
  if (element === undefined) { return; }

  const startAnimation = throttle(() => {
    if (isScrolledInViewport(element)) {
      classNames.forEach(name => {
        const target = element.querySelector(name);

        if(target.classList.contains('pre-animation')){
          target.classList.remove('pre-animation')
        }
        target.classList.add('animation')
      })

      window.removeEventListener('scroll', startAnimation);
    }
  }, 100)

  window.addEventListener('scroll', startAnimation);
  if (isScrolledInViewport(element)) {
    startAnimation(element);
  }
}