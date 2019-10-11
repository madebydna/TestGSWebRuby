const wholeNumbers = (value, delimiter) =>{
  const validNumbers = new RegExp('^[0-9]+$');
  const numberSet = String(value).split(delimiter);

  if (numberSet.length < 2 && numberSet[0].match(validNumbers)){
    return numberSet[0];
  }

  return undefined;
};

const findDenomination = value => {
  if(value.length > 12){
    return 'trillion';
  }else if(value.length > 9){
    return 'billion';
  }else if(value.length > 6){
    return 'million';
  }else if(value.length > 3){
    return 'thousand';
  }else{
    return '';
  }
};

const insertDecimal = (value, fraction) =>{
  if(fraction){
    return `${value}.${fraction}`;
  }else{
    return value;
  }
};

const convertNumber = value =>{
  const lengthOfNumber = value.length;
  let truncated;
  let fraction;

  if (lengthOfNumber > 12) {
    truncated = value.slice(0, lengthOfNumber - 12);
    fraction = value[truncated.length]
  } else if (lengthOfNumber > 9) {
    truncated = value.slice(0, lengthOfNumber - 9);
    fraction = value[truncated.length]
  } else if (lengthOfNumber > 6) {
    truncated = value.slice(0, lengthOfNumber - 6);
    fraction = value[truncated.length]
  } else if (lengthOfNumber > 3) {
    truncated = value.slice(0, lengthOfNumber - 3);
    fraction = value[truncated.length]
  } else {
    truncated = value;
  }
  return insertDecimal(truncated, fraction);
};

export const humanReadableNumber = value => {
  const wholeNumber = wholeNumbers(value, '.');
  if (wholeNumber){
    return `${convertNumber(wholeNumber)} ${findDenomination(wholeNumber)}`;
  }
  return undefined;
}


