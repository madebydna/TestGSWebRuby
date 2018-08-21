import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import TocItem from './toc_item';

const cityTocItems = [
  {
    key: 'schools',
    label: t('schools'),
    anchor: '',
    selected: true
  },
  {
    key: 'school districts',
    label: t('school districts'),
    anchor: '',
    selected: false
  }
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
  // {
  //   key: 'nearby homes for sale & rent',
  //   label: t('Schools'),
  //   anchor: '',
  // selected: false
  // },
  // {
  //   key: 'Reviews',
  //   label: t('Schools'),
  //   anchor: '',
  // selected: false
  // }
]

class Toc extends React.Component {
  static defaultProps = {
    schools: [],
    students: [],
    schoolDistricts: [],
    reviews: []
  };

  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.object),
    students: PropTypes.arrayOf(PropTypes.object),
    schoolDistricts: PropTypes.arrayOf(PropTypes.object),
    reviews: PropTypes.arrayOf(PropTypes.object)
  };

  constructor(props) {
    super(props);
    this.state = {tocItems: this.selectTocItems()};
    this.handleClick = this.handleClick.bind(this);
  }

  selectTocItems(){
    // logic for selecting toc items. Stubbed out for now.
    return cityTocItems;
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

  handleClick(tocItem){
    this.unselectAllTocItems();
    this.setState({tocItems: this.selectTocItem(tocItem)})
  }

  renderTocItems(){
    return (
      <ul>
        {this.state.tocItems.map(item => {
          return <TocItem handleClick={this.handleClick} key={`${item.key}-selected:${item.selected}`} id={item.key} label={capitalize(item.label)} selected={item.selected} />
        })}
      </ul>
    )
  }

  render(){
    return this.renderTocItems()
  }
}

export default Toc;