/* eslint-disable import/prefer-default-export */

import { GS_WEB_NAME_UPDATE } from '../constants/gsWebConstants';

export const updateName = (text) => ({
  type: GS_WEB_NAME_UPDATE,
  text,
});
