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

$('body').on('click', '.js-emailSharingLinks', function () {
  window.location.href = ($(this).data("link"));
  return false;
})

$('body').on('click', '.js-sharingLinks', function () {
  var url = $(this).data("link") + encodeURIComponent($(this).data("url"));
  if($(this).data("siteparams") !== undefined) {
    url +=  $(this).data("siteparams");
  }
  popupCenter(url, $(this).data("type"), 700, 300)
  return false;
})

$(commonPageInit());
