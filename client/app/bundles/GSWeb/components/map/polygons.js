export const SCHOOL = 'SCHOOL';
export const DISTRICT = 'DISTRICT';

export default function createPolygonFactory(googleMaps) {
  const polygonFactory = {
    createPolygon: function(coordinates) {
      return new googleMaps.Polygon({
        paths: this.getPolygonPath(coordinates),
        strokeColor: this.strokeColor || '#FF7800',
        strokeOpacity: 1,
        strokeWeight: 2,
        fillColor: this.fillColor || '#46461F',
        fillOpacity: 0.25,
        zIndex: this.zIndex || 1
      });
    },

    getPolygonPath: function(coordinates) {
      let paths = [];

      if (coordinates) {
        for (let i=0; i < coordinates.length; i++){
          for (let j=0; j < coordinates[i].length; j++){
            let path=[];
            for (let k=0; k < coordinates[i][j].length; k++){
              let ll = new googleMaps.LatLng(coordinates[i][j][k][1],coordinates[i][j][k][0]);
              path.push(ll);
            }
            paths.push(path);
          }
        };
      }
      return paths;
    }
  };

  const schoolPolygonFactory =  Object.assign(Object.create(polygonFactory), {
    strokeColor: '#FF7800',
    zIndex: 1,
    fillColor: '#46461F'
  });

  const districtPolygonFactory =  Object.assign(Object.create(polygonFactory), {
    strokeColor: '#2092C4',
    zIndex: 1,
    fillColor: 'rgba(0,0,0,0.2)'
  });

  const factories = {
    SCHOOL: schoolPolygonFactory,
    DISTRICT: districtPolygonFactory
  };

  return {
    createPolygon: (type, ...otherArgs) => factories[type].createPolygon(...otherArgs)
  }
}

