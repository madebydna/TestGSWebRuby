import { getState }  from 'store/appStore';

const QUALAROO_MODULE_KEY = {
  advanced_coursework: 'd8fa4702-59cd-435c-a922-9409acaf81c8',
  advanced_stem: '6a8ccb75-0c22-4433-a220-97db8fd509df',
  race_ethnicity: 'a0e5e5a5-d6d6-45c6-99e4-4e1e06863f89',
  low_income_students: '6bb9534f-6abf-4feb-b262-db8059ba49ee',
  students_with_disabilities: '2cfa01ac-bd57-44a3-abb8-0684737688f1',
  general_information_public: '13cc9732-4b35-4092-b986-358c71d5b7fe',
  general_information_private: '228904ba-a897-4581-8bf1-c49be0a3f259',
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
