export const getSchools = state => {
  let schools = Object.values(state.schools);
  return schools;
}

export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      schools: []
    };
  }

  switch (action.type) {
    default:
      return state;
  }
};
