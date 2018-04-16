import React from 'react';

let resultsFound = function(total, singularResultType, pluralResultType) {
  if(total == 1) {
    return total + ' ' + singularResultType + 'found'
  } else {
    return total + ' ' + pluralResultType + 'found'
  }
}

const PaginationSummary = ({
  className='',
  total=0,
  singularResultType='thing',
  pluralResultType='things',
  location='',
  index_of_first_item=0,
  index_of_last_item=0,
  ...otherAttributes
}) => {
  return <div className={'' + className} >
    <div>{resultsFound(total, singularResultType, pluralResultType)}{location && 'in ' + location}</div>
    <div>Showing {this.props.index_of_first_item} to {this.props.index_of_last_item} of {this.props.total} schools</div>
  </div>;
};

export default AnchorButton;
