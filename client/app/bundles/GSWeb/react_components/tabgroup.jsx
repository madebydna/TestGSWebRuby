import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';

class TabGroup extends React.Component {
  static propTypes = {
    options: PropTypes.array,
    activeOption: PropTypes.string,
    onSelect: PropTypes.func
  };

  static defaultProps = {
    options: [],
    activeOption: "",
  };

  constructor(props){
    super(props)
  }

  render(){
    const tabs = this.props.options.map((option, idx) => {
      if(option.key === this.props.activeOption){
        return(
          <React.Fragment>
            <span onClick={() => this.props.onSelect(option.key)} className="tab-selected" key={`${option.key}`}>WORKING</span>
            {(idx !== this.props.options.length -1) && <span className="divider"/>}
          </React.Fragment>
        ) 
      }else{
        return(
          <React.Fragment>
            <span onClick={() => this.props.onSelect(option.key)} className="tab" key={`${option.key}`}>{option.label}</span>
            {(idx !== this.props.options.length -1) && <span className="divider"/>}
          </React.Fragment>
        ) 
      }
    })
    return(
      <div className="tab-group">
        {tabs}
      </div>
    )
  }
}

export default TabGroup;
 