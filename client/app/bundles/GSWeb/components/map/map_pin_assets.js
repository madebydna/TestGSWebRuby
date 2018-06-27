import { t } from '../../util/i18n';

function mapPinColor(rating) {
  return {
    1: '#F36917',
    2: '#e68618',
    3: '#dda11e',
    4: '#d3b722',
    5: '#bec022',
    6: '#a3be21',
    7: '#87b31e',
    8: '#6ca81f',
    9: '#549e22',
    10: '#449224'
  }[rating]
}

function createDefaultPinWithRating(rating,color, assigned=false){

  return(`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" width="40" height="50" viewBox="0 0 40 50">\
        <g fill="none" fill-rule="evenodd" transform="translate(0 -4)">\
        <path fill="#999" d="M14.26 42.417C6.122 40.019.187 32.547.187 23.701.188 12.92 9.004 4.18 19.878 4.18S39.567 12.92 39.567 23.7c0 8.132-5.014 15.102-12.144 18.038l-6.767 11.575-6.397-10.897z"/>\
        <ellipse cx="19.957" cy="23.813" fill="${color}" rx="18" ry="18"/>\
        <text fill="#FFF" font-family="RobotoSlab-Bold, Roboto Slab" font-size="18" font-weight="bold">\
        <tspan x="${ rating == 10 ? 6 : 11}" y="29">${rating}</tspan> <tspan x="${ rating == 10 ? 24 : 22}" y="29" font-size="8" font-weight="normal">/10</tspan>\
        </text>\
        </g>\
        </svg>`)
}

function createHighlightedPinWithRating(rating, color){
  return (`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="40" height="50" viewBox="0 0 40 50">\
        <defs>\
        <circle id="a" cx="20" cy="24" r="18"/>\
        </defs>\
        <g fill="none" fill-rule="evenodd">\
        <path fill="${color}" d="M14.26 38.417C6.122 36.019.187 28.547.187 19.701.188 8.92 9.004.18 19.878.18S39.567 8.92 39.567 19.7c0 8.132-5.014 15.102-12.144 18.038l-6.767 11.575-6.397-10.897z"/>\
        <g transform="translate(0 -4)">\
        <use fill="#FFF" xlink:href="#a"/>\
        <circle cx="20" cy="24" r="17" stroke="${color}" stroke-width="2"/>\
        </g>\
        <text fill="${color}" font-family="RobotoSlab-Bold, Roboto Slab" font-size="18" font-weight="bold" transform="translate(0 -4)">\
        <tspan x="${ rating == 10 ? 6 : 11}" y="29">${rating}</tspan> <tspan x="${ rating == 10 ? 24 : 22}" y="29" font-size="8" font-weight="normal">/10</tspan>\
        </text>\
        </g>\
        </svg>`)
}

function createAssignedHighlightedPinWithRating(rating, color){
  return (`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" width="59" height="75" viewBox="0 0 59 75">\
    <defs>
      <circle id="a" cx="20" cy="24" r="18"/>
    </defs>
    
    <g fill="none" fill-rule="evenodd">\
      <g transform="translate(10 21)">\
        <path fill="${color}" d="M14.26 42.417C6.122 40.019.187 32.547.187 23.701.188 12.92 9.004 4.18 19.878 4.18S39.567 12.92 39.567 23.7c0 8.132-5.014 15.102-12.144 18.038l-6.767 11.575-6.397-10.897z"/>\
        <ellipse cx="19.957" cy="23.813" fill="#FFF" rx="16.957" ry="16.813"/>\\
        <circle cx="20" cy="24" r="17" stroke="${color}" stroke-width="2"/>\

        <text fill="${color}" font-family="RobotoSlab-Bold, Roboto Slab" font-size="18" font-weight="bold">\
          <tspan x="${ rating == 10 ? 6 : 11}" y="29">${rating}</tspan> <tspan x="${ rating == 10 ? 24 : 22}" y="29" font-size="8" font-weight="normal">/10</tspan>\
        </text>\
      </g>\
      <path fill="#176997" d="M32.968 19l-3.655 3.655L25.658 19H0V0h59v19H32.968z"/>\
      <text fill="#FFF" font-family="OpenSans-Bold, Open Sans" font-size="10" font-weight="bold" letter-spacing=".002">\
        <tspan x="5.192" y="13">${t('assigned')}</tspan>\
      </text>\
    </g>\
  </svg>`)
}

function createAssignedPinWithRating(rating, color){
  return (`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" width="59" height="75" viewBox="0 0 59 75">\
        <g fill="none" fill-rule="evenodd">\
        <g transform="translate(10 21)">\
        <path fill="#999" d="M14.26 42.417C6.122 40.019.187 32.547.187 23.701.188 12.92 9.004 4.18 19.878 4.18S39.567 12.92 39.567 23.7c0 8.132-5.014 15.102-12.144 18.038l-6.767 11.575-6.397-10.897z"/>\
        <ellipse cx="19.957" cy="23.813" fill="${color}" rx="18" ry="18"/>\
        <text fill="#FFF" font-family="RobotoSlab-Bold, Roboto Slab" font-size="18" font-weight="bold">\
        <tspan x="${ rating == 10 ? 6 : 11}" y="30">${rating}</tspan> <tspan x="${ rating == 10 ? 24 : 22}" y="30" font-size="8">/10</tspan>\
        </text>\
        </g>\
        <path fill="#176997" d="M32.968 19l-3.655 3.655L25.658 19H0V0h59v19H32.968z"/>\
        <text fill="#FFF" font-family="OpenSans-Bold, Open Sans" font-size="10" font-weight="bold" letter-spacing=".002">\
        <tspan x="5.192" y="13">${t('assigned')}</tspan>\
        </text>\
        </g>\
        </svg>`)
}

function createPinWithoutRating(highlighted){
  return (`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" width="26" height="33" viewBox="0 0 26 33">\
        <g fill="none" fill-rule="evenodd">\
        <path fill="#999" d="M9.323 25.35c-5.32-1.568-9.2-6.454-9.2-12.237C.123 6.063 5.887.348 12.997.348S25.87 6.063 25.87 13.113c0 5.316-3.278 9.874-7.94 11.793l-4.424 7.569-4.183-7.125z"/>\
        <circle cx="13.077" cy="12.692" r="10.769" stroke="${highlighted ? '#707A80' : ''}" fill="${highlighted ? '#fff' : '#707A80'}"/>\
        </g>\
        </svg>`)
}

function createAssignedPinWithoutRating(highlighted){
  return (`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" width="59" height="58" viewBox="0 0 59 58">\
        <g fill="none" fill-rule="evenodd">\
        <g transform="translate(16 25)">\
        <path fill="#FFF" d="M9.323 25.35c-5.32-1.568-9.2-6.454-9.2-12.237C.123 6.063 5.887.348 12.997.348S25.87 6.063 25.87 13.113c0 5.316-3.278 9.874-7.94 11.793l-4.424 7.569-4.183-7.125z"/>\
        <circle cx="13.077" cy="12.692" r="${highlighted ? '10.019' : '10.769'}" fill="${highlighted ? '' : '#707A80'}" stroke="${highlighted ? '#707A80' : ''}" stroke-width="${highlighted ? '1.5' : ''}"/>\
        </g>\
        <path fill="#176997" d="M32.968 19l-3.655 3.655L25.658 19H0V0h59v19H32.968z"/>\
        <text fill="#FFF" font-family="OpenSans-Bold, Open Sans" font-size="10" font-weight="bold" letter-spacing=".002">\
        <tspan x="5.192" y="13">${t('assigned')}</tspan>\
        </text>\
        </g>\
        </svg>`)
}

const addressPin = (`data:image/svg+xml;utf-8,<svg xmlns="http://www.w3.org/2000/svg" width="25" height="34" viewBox="0 0 25 34">\
        <g fill="none" fill-rule="evenodd">\
        <path fill="#323232" fill-rule="nonzero" d="M12.5 0C5.596 0 0 5.911 0 13.204c0 7.877 9.465 18.042 11.923 20.548.323.33.83.33 1.154 0C15.535 31.246 25 21.082 25 13.204 25 5.91 19.404 0 12.5 0z"/>\
        <circle cx="12.5" cy="11.5" r="4.5" fill="#FFF"/>\
        </g>\
        </svg>`)

export {mapPinColor,createDefaultPinWithRating,createHighlightedPinWithRating,createAssignedPinWithRating,
  createPinWithoutRating,createAssignedPinWithoutRating,addressPin, createAssignedHighlightedPinWithRating};