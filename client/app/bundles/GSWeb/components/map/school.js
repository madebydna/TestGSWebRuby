//TODO: change hardcoded assets
import Mappable from './mappable';

const School = function(){
  if (arguments.length) $.extend(this, arguments[0]);

  this.iconSize = this.schoolType == 'private' ? 35 : 32;

  if (this.schoolType == 'private') {
    if(this.iconUrl = this.isNewGSRating === true) {
      '/assets/icons/google_map_pins/120906-mapPins-private-RYG.png';
    } else {
      '/assets/icons/google_map_pins/120906-mapPins-private-RYG.png';
    }
  } else {
    if(this.iconUrl = this.isNewGSRating === true) {
      '/assets/icons/google_map_pins/120906-mapPins-public-RYG.png';
    } else {
      '/assets/icons/google_map_pins/120906-mapPins-public-RYG.png';
    }
  }

  Mappable.apply(this, arguments);
};
School.prototype = $.extend(Mappable.prototype, {});
School.prototype.constructor = School;

export default School;
