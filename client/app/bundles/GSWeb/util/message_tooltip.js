import {extend} from 'lodash';

// Look here for all options
// https://tipso.object505.com/
export const showMessageTooltip = function(attachToObj, options) {
  let defaults = {
    content: 'No Content Specified',
    background: '#202124',
    color: '#FFFFFF',
    position: 'bottom',
    useTitle: false,
    width: 120,
    speed: 0,
    offsetY: -10,
    onShow:
        setTimeout(function () {
          attachToObj.tipso('hide');
        }, 1000)
  };
  let actualOptions = extend({}, defaults, options || {});

  attachToObj.tipso(actualOptions).tipso('show');
}

