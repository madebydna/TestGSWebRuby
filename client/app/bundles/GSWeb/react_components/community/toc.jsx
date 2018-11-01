import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import { scrollToElement } from 'util/scrolling';
import TocItem from './toc_item';

class Toc extends React.Component {
  static defaultProps = {
    suppressReviews: true,
    suppressDistricts: true
  };

  static propTypes = {
    tocItems: PropTypes.arrayOf(PropTypes.object).isRequired
  };

  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
    this.state = {tocItems: this.props.tocItems};
  }

  unselectAllTocItems(){
    return this.state.tocItems.map(item => { return item.selected = false} );
  }

  selectTocItem(tocItemKey){
    return this.state.tocItems.map(item => {
      if (item.key === tocItemKey) {item.selected = true}
      return item;
    })
  }

  handleClick(key, selector){
    this.unselectAllTocItems();
    this.setState({tocItems: this.selectTocItem(key)}, scrollToElement(selector,()=>{}, -60))
  }

  renderTocItems(){
    return (
      <ul>
        {this.state.tocItems.map(item => {
          return item && <TocItem handleClick={this.handleClick} key={`${item.key}-selected:${item.selected}`} id={item.key} anchor={item.anchor} label={capitalize(item.label)} selected={item.selected} />
        })}
      </ul>
    )
  }

  render(){
    return this.renderTocItems()
  }
}

export default Toc;