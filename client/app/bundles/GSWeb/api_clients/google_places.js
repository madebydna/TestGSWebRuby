import { getScript } from 'util/dependency';
import log from 'util/log';

let initializing = false;
let initialized = false;
const onInitCallbacks = [];
const scriptURL =
  '//maps.googleapis.com/maps/api/js?key=AIzaSyD76GwhrI6Th1GN8S0kPLCjESkNs-MtTKg&amp;libraries=places&amp;sensor=false';

const getPlacesApi = () => window.google.maps.places;

const processCallbacks = () => {
  while (onInitCallbacks.length > 0) {
    onInitCallbacks.shift().call(this, { placesApi: getPlacesApi() });
  }
};

const enqueueCallbacks = callbacks => onInitCallbacks.push(...callbacks);

const onInitialized = () => {
  initialized = true;
  processCallbacks();
};
window.GS_onGooglePlacesInitialized = onInitialized;

const init = (...callbacks) => {
  enqueueCallbacks(callbacks);
  if (initialized) {
    processCallbacks();
  } else if (!initializing) {
    initializing = true;
    getScript(`${scriptURL}&callback=window.GS_onGooglePlacesInitialized`);
  }
};

const getAddressPredictions = (query, callback) => {
  const placesApi = getPlacesApi();
  const autocompleteService = new placesApi.AutocompleteService();
  autocompleteService.getPlacePredictions(
    {
      input: query,
      types: ['address'],
      componentRestrictions: { country: 'us' }
    },
    (predictions, status) => {
      if (status !== placesApi.PlacesServiceStatus.OK) {
        log('Google Places call failed in getAddressPredictions');
      } else {
        callback.call(
          this,
          predictions.map(prediction =>
            prediction.description.replace(', USA', '')
          )
        );
      }
    }
  );
};

export { init, getAddressPredictions };
