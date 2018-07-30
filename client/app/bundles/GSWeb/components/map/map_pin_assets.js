import { t } from '../../util/i18n';

const GRAY = 'rgb(150,150,150)';
const DARK_GRAY = 'rgb(104,104,104)';
const WHITE = 'rgb(255,255,255)';
const LIGHT_BLUE = 'rgb(232,247,250)';
const PREFIX = 'data:image/svg+xml;base64,';

const mapPinColor = rating =>
  ({
    1: 'rgb(243,105,23)',
    2: 'rgb(230,134,24)',
    3: 'rgb(221,161,30)',
    4: 'rgb(211,183,34)',
    5: 'rgb(190,192,34)',
    6: 'rgb(163,190,33)',
    7: 'rgb(135,179,30)',
    8: 'rgb(108,168,31)',
    9: 'rgb(84,158,34)',
    10: 'rgb(68,146,36)'
  }[rating]);

const assignedPath = `<path fill="rgb(23,105,151)" d="M32.968 19l-3.655 3.655L25.658 19H0V0h59v19H32.968z"/>
  <text fill="${WHITE}" font-family="OpenSans-Bold, Open Sans" font-size="10" font-weight="bold" letter-spacing=".002">
    <tspan x="5.192" y="13">${t('assigned')}</tspan>
  </text>`;

const ratingPinOutline = color =>
  `<path fill="${color}" d="M14.26 42.417C6.122 40.019.187 32.547.187 23.701.188 12.92 9.004 4.18 19.878 4.18S39.567 12.92 39.567 23.7c0 8.132-5.014 15.102-12.144 18.038l-6.767 11.575-6.397-10.897z"/>`;

const highlightedRatingPinOutline = color =>
  `<path fill="${color}" d="M14.26 38.417C6.122 36.019.187 28.547.187 19.701.188 8.92 9.004.18 19.878.18S39.567 8.92 39.567 19.7c0 8.132-5.014 15.102-12.144 18.038l-6.767 11.575-6.397-10.897z"/>`;

const pinWithoutRatingOutline = highlighted =>
  `<path
    fill="${highlighted ? DARK_GRAY : DARK_GRAY}"
    d="M9.323 25.35c-5.32-1.568-9.2-6.454-9.2-12.237C.123 6.063 5.887.348 12.997.348S25.87 6.063 25.87 13.113c0 5.316-3.278 9.874-7.94 11.793l-4.424 7.569-4.183-7.125z"
  />`;

const ratingText = (rating, color, { transform } = {}) =>
  `<text
    fill="${color}"
    font-family="RobotoSlab-Bold, Roboto Slab"
    font-size="18"
    font-weight="bold"
    transform="${transform}">
      <tspan
        x="${rating === 10 ? 6 : 11}"
        y="29">${rating}</tspan> <tspan
        x="${rating === 10 ? 24 : 22}"
        y="29"
        font-size="8"
        font-weight="normal"
      >/10</tspan>
    </text>`;

const ratingPinDisc = color =>
  `<circle
    cx="20"
    cy="23.5"
    r="18"
    fill="${color}"
  />`;

const highlightedRatingPinDisc = color =>
  `<circle
    cx="20"
    cy="23.5"
    r="17"
    fill="${WHITE}"
    stroke="${color}"
    stroke-width="2"
  />`;

const pinWithoutRatingDisc = highlighted =>
  `<circle
    cx="13"
    cy="13"
    r="11.5"
    stroke="${highlighted ? DARK_GRAY : DARK_GRAY}"
    fill="${highlighted ? WHITE : GRAY}"
  />`;

const svg = (width, height, content) =>
  PREFIX +
  btoa(
    `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">${content}</svg>`
  );

const createDefaultPinWithRating = (rating, color) =>
  svg(
    40,
    50,
    `<g transform="translate(0 -4)">
      ${ratingPinOutline(DARK_GRAY)}
      ${ratingPinDisc(color)}
      ${ratingText(rating, WHITE)}
    </g>`
  );

const createHighlightedPinWithRating = (rating, color) =>
  svg(
    40,
    50,
    `${highlightedRatingPinOutline(color)}
    <g transform="translate(0 -4)">
      ${highlightedRatingPinDisc(color)}
    </g>
    ${ratingText(rating, color, { transform: 'translate(0 -4)' })}`
  );

const createAssignedHighlightedPinWithRating = (rating, color) =>
  svg(
    59,
    75,
    `<g transform="translate(10 25)">
      ${highlightedRatingPinOutline(color)}
      <g transform="translate(0 -4)">
        ${highlightedRatingPinDisc(color)}
        ${ratingText(rating, color)}
      </g>
    </g>
    ${assignedPath}`
  );

// tspan y's were 30 on this one before refactoring out ratingText...
const createAssignedPinWithRating = (rating, color) =>
  svg(
    59,
    75,
    `<g transform="translate(10 21)">
      ${ratingPinOutline(DARK_GRAY)}
      ${ratingPinDisc(color)}
      ${ratingText(rating, WHITE)}
    </g>
    ${assignedPath}`
  );

const createPinWithoutRating = highlighted =>
  svg(
    26,
    33,
    `${pinWithoutRatingOutline(highlighted)}
    ${pinWithoutRatingDisc(highlighted)}`
  );

const createAssignedPinWithoutRating = highlighted => {
  svg(
    59,
    58,
    `<g transform="translate(16 25)">
      ${pinWithoutRatingOutline(highlighted)}
      ${pinWithoutRatingDisc(highlighted)}
    </g>
    ${assignedPath}`
  );
};

const addressPin = svg(
  25,
  34,
  `<g fill="none" fill-rule="evenodd">
    <path fill="rgb(50,50,50)" fill-rule="nonzero" d="M12.5 0C5.596 0 0 5.911 0 13.204c0 7.877 9.465 18.042 11.923 20.548.323.33.83.33 1.154 0C15.535 31.246 25 21.082 25 13.204 25 5.91 19.404 0 12.5 0z"/>
    <circle cx="12.5" cy="11.5" r="4.5" fill="${WHITE}"/>
  </g>`
);

export {
  mapPinColor,
  createDefaultPinWithRating,
  createHighlightedPinWithRating,
  createAssignedPinWithRating,
  createPinWithoutRating,
  createAssignedPinWithoutRating,
  addressPin,
  createAssignedHighlightedPinWithRating
};
