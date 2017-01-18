//TODO: hardcoded color values

const Mappable = function(){
  var lat, lon, name;
  if (arguments.length) {
    var inputs = arguments[0];
    lat = inputs.lat, lon = inputs.lon;
    name = inputs.name;
  }
  this.getPosition = function(){return new google.maps.LatLng(lat, lon);}
  this.getName = function(){return name;}
};

Mappable.prototype = {
  constructor: Mappable,
  getMarker: function(){
    if (this.marker) return this.marker;
    return this.marker = new google.maps.Marker({
      position: this.getPosition(),
      title: this.getName(),
      // icon: this.getMarkerImage(),
      shape: this.getMarkerShape(),
      zIndex: 1
    });
  },

  getMarkerShape: function() {
    return (this.type=='district') ?
      {coord: [8,4, 37,4, 37,33, 32,33, 23,42, 14,33, 8,33], type: 'poly'} :
      {coord: [1,0, 29,0, 29,31, 1,31], type: 'poly'};
  },
  
  getMarkerOrigin: function() {
    var xoffset = this.iconSize * 10;
    if (this.rating > 0 && this.rating < 11) {
      xoffset = this.iconSize * (this.rating - 1);
    }
    return new google.maps.Point(xoffset, 0);
  },
  
  getMarkerAnchor: function() {
    return new google.maps.Point(this.iconSize/2,this.iconSize);
  },
  
  getMarkerImage: function(){
    return new google.maps.MarkerImage(this.iconUrl ,
      new google.maps.Size(this.iconSize,this.iconSize), this.getMarkerOrigin(), this.getMarkerAnchor()
    );
  },
  
  isPolygonShown: function () {
    return (this.polygon && this.polygon.getMap()!=null && this.polygon.getPaths() && this.polygon.getPaths().length>0);
  },
  
  getPolygon: function ( level ){
    if (this.polygon) return this.polygon;
    this.polygon = new google.maps.Polygon({
      paths: this.getPolygonPath( level ),
      strokeColor: this.strokeColor || '#FF7800',
      strokeOpacity: 1,
      strokeWeight: 2,
      fillColor: this.fillColor || '#46461F',
      fillOpacity: 0.25,
      zIndex: this.zIndex || 1
    });
    this.polygon.key = this.getKey();
    this.polygon.type = this.getType();
    return this.polygon;
  },
  
  getPolygonPath: function ( level ) {
    var coords, paths = new Array();
    if (level == 'e') { level = 'p' }

    var boundaries = this.boundaries[level.toUpperCase()];
    if(boundaries) {
      coords = [boundaries.coordinates];
    }

    if (coords) {
      for (var i=0;i < coords.length;i++){
        for (var j=0;j<coords[i].length;j++){
          var path=[];
          for (var k=0;k<coords[i][j].length;k++){
            var ll = new google.maps.LatLng(coords[i][j][k][1],coords[i][j][k][0]);
            path.push(ll);
          }
          paths.push(path);
        }
      };
    }
    return paths;
  },
  
  getType: function () {
    return this.type;
  },
  
  getKey: function (){
    return this.type + '-' + this.state + '-' + this.id;
  }
};

export default Mappable;
