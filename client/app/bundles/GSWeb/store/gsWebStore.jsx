import { createStore } from 'redux';
import gsWebReducer from '../reducers/gsWebReducer';

const configureStore = (railsProps) => (
  createStore(gsWebReducer, railsProps)
);

export default configureStore;
