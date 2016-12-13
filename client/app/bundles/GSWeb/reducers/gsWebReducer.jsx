import { combineReducers } from 'redux';
import { GS_WEB_NAME_UPDATE } from '../constants/gsWebConstants';

const name = (state = '', action) => {
  switch (action.type) {
    case GS_WEB_NAME_UPDATE:
      return action.text;
    default:
      return state;
  }
};

const gsWebReducer = combineReducers({ name });

export default gsWebReducer;
