import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import { scrollToElement } from 'util/scrolling';
import { isScrolledInViewport } from 'util/viewport';
import TocItem from './toc_item';
import { throttle } from 'lodash';


class Toc extends React.Component {
  static defaultProps = {
    tocItems: [],
  };

  static propTypes = {
    tocItems: PropTypes.arrayOf(PropTypes.object).isRequired,
  };

  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
    this.state = {
      tocItems: this.props.tocItems,
      selectedToc: null
    };
  }

  unselectAllTocItems(){
    return this.state.tocItems.map(item => { return item.selected = false} );
  }

  componentDidMount(){
    this.updateActiveTocItem()
    window.addEventListener('scroll', throttle(this.updateActiveTocItem, 100))
  }

  componentDidUpdate(prevProps, prevState){
    if (prevState.selectedToc !== this.state.selectedToc){
      this.unselectAllTocItems();
      this.setState({
        tocItems: this.selectTocItem(this.state.selectedToc)
      })
    }
  }

  updateActiveTocItem = () => {
    const tocElements = [...document.querySelectorAll('.module-section')].filter(ele => isScrolledInViewport(ele))
    const selectedToc = tocElements ? tocElements[0].id : [];
    
    this.setState({
      selectedToc
    })
  }

  selectTocItem(tocItemKey){
    return this.state.tocItems.map(item => {
      if (item.key === tocItemKey) {item.selected = true}
      return item;
    })
  }

  handleClick(selector){
    scrollToElement(selector,()=>{}, -60)
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