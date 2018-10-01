import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import { scrollToElement } from 'util/scrolling';
import TocItem from './toc_item';

const SCHOOL_DISTRICTS = 'school districts'
const SCHOOLS = 'schools'
const REVIEWS = 'Reviews'


const cityTocItems = [
  {
    key: SCHOOLS,
    label: t(SCHOOLS),
    anchor: '#schools',
    selected: true
  },
  {
    key: SCHOOL_DISTRICTS,
    label: t(SCHOOL_DISTRICTS),
    anchor: '#districts',
    selected: false
  },
  // {
  //   key: 'students',
  //   label: t('students'),
  //   anchor: '',
  // selected: false
  // },
  // {
  //   key: 'community resources',
  //   label: t('community resources'),
  //   anchor: '',
  // selected: false
  // },
  // {
  //   key: 'map',
  //   label: t('Schools'),
  //   anchor: '',
  // selected: false
  // },
  {
    key: 'nearby homes for sale & rent',
    label: t('nearby homes for sale & rent'),
    anchor: '#homes-and-rentals',
    selected: false
  },
  {
    key: 'Reviews',
    label: t(REVIEWS),
    anchor: '#reviews',
    selected: false
  }
]

class Toc extends React.Component {
  static defaultProps = {
    schools: [],
    students: [],
    districts: [],
    reviews: [],
    suppressReviews: true,
    suppressDistricts: true
  };

  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.object),
    students: PropTypes.arrayOf(PropTypes.object),
    districts: PropTypes.arrayOf(PropTypes.object),
    suppressReviews: PropTypes.bool,
    suppressDistricts: PropTypes.bool
  };

  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
    this.state = {tocItems: this.selectTocItems()};
  }

  selectTocItems(){
    const suppressDistricts = this.props.suppressDistricts;
    const suppressReviews = this.props.suppressReviews;
    return cityTocItems.filter(tocItem=>{
      if(tocItem.key === SCHOOL_DISTRICTS && suppressDistricts ) {
        return false;
      } else if (tocItem.key === REVIEWS && suppressReviews){
        return false;
      }
      return true;
    })
  }

  renderHelp(){
    // ollie icon and translated 'Help'; ModalTooltip
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

  findTocItemSelector(tocItemKey){

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