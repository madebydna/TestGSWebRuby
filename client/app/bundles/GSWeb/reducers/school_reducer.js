export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      state: null,
      id: null
    };
  }

  switch (action.type) {
    default:
      return state;
  }
};
