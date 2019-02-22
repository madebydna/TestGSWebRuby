import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import Search from './react_components/search/search';
import MySchoolList from './react_components/my_school_list';
import commonPageInit from './common';

window.store = configureStore({
  search: gon.search
});

ReactOnRails.register({
  Search,
  MySchoolList
});

$(commonPageInit());
