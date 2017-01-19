//TODO: change hardcoded assets
import Mappable from './mappable';

const School = function(){
  if (arguments.length) $.extend(this, arguments[0]);

  // this.schoolType == 'private' ? true : false
  this.iconSize = 41;
  this.iconUrl = '/assets/icons/google_map_pins/school-pins.png';
  Mappable.apply(this, arguments);
};
School.prototype = $.extend(Mappable.prototype, {});
School.prototype.constructor = School;

export default School;
