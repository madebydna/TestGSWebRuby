export default function checkRequiredProps() {
  if (!this.requiredProps) {
    return;
  }
  for(var i = 0; i < this.requiredProps.length; i++) {
    var prop = this.requiredProps[i];
    if (!this.hasOwnProperty(prop) || this[prop] == undefined) {
      var error = prop + " is required but is undefined";
      this.log([error, this]);
      throw error;
      return;
    }
  }
  return this;
}
