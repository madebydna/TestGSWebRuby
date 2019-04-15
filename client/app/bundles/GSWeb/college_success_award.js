import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import Search from './react_components/search/search';
import CollegeSuccessAward from './react_components/college_success_award';
import commonPageInit from './common';

window.store = configureStore({
  search: gon.search
});

ReactOnRails.register({
  Search,
  CollegeSuccessAward
});

$(commonPageInit());
