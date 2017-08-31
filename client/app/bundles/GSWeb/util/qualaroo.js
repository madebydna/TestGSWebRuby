import { getState }  from 'store/appStore';

const QUALAROO_MODULE_KEY = {
  nearby_schools: '7127048b-a2e6-491e-8f23-aa335f92b19a'
}

const qualarooLink = function(module) {
  let school = getState().school;
  if(school) {
    return 'https://s.qualaroo.com/45194/' + 
      QUALAROO_MODULE_KEY[module] + 
      '?state=' + school.state + 
      '&school=' + school.id;
  }
  return '';
}

export { qualarooLink }
