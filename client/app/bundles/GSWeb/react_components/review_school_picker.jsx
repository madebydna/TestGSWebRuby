import React from "react";
import ReviewPageAlternateSelector from "./review_page_alternate_selector";
import ReviewPageSearchBox from "./review_page_search_box";
import PropTypes from "prop-types";

export default class ReviewSchoolPicker extends React.Component {

  // static defaultProps = {
  //   osp: false
  // };

  // static propTypes = {
  //   osp: PropTypes.bool
  // };

  // PropTypes.checkPropTypes(defaultProps, propTypes, 'osp', 'ReviewSchoolPicker');

  constructor(props) {
    super(props);
    this.osp = this.props.osp;
    this.state = {
      autoCompleteActive: true
    }
  }
  handleToggle = (value) => {
    console.log("handleToggle: "+value);
    // this.setState({autoCompleteActive: value});
  }

  render() {
    return (
        this.schoolSelectorObject()
    )
  }

  schoolSelectorObject() {
    if (this.state.autoCompleteActive) {
      return (
          <div className="search-bar-osp js-autocompleteFieldContainer ma picker-border">
            <div className="full-width">
              <ReviewPageSearchBox osp={this.props.osp} resultTypes={this.props.resultTypes} showSearchAllOption={this.props.showSearchAllOption} showSearchButton={this.props.showSearchButton} statusCallback={this.handleToggle} />
            </div>
          </div>
      )
    }
    return <ReviewPageAlternateSelector />;
  }
}
//
//   render(){
//       return(
// <div className="js-autocompleteContainer clearfix">
// <% #don't see your school      %>
//   <div class="subtitle-sm tac" style="height:35px;">
//     <a class="js-doNotSeeResult dn pointer <%=linkClass%>"
//       data-no-result-text="<%=t('.do_not_see_school_text')%>"
//       data-return-to-search-text="<%= t('.return_to_original_search_text') %>"
//       data-state="<%= params['state'] %>">
//       <%= t('.do_not_see_school_text') %>
//     </a>
//   </div>
//   <% #autocomplete search bar      %>
//   <div class="search-bar-osp js-autocompleteFieldContainer ma picker-border">
//     <div class="full-width">
//       <%= react_component(component_name, props: {
//   resultTypes: ['Schools'],
//   showSearchAllOption: false,
//   showSearchButton: false
// }) %>
//     </div>
//   </div>
//
//   <% #list of select boxes      %>
//   <div class="js-selectListsContainer dn ma picker-border picker-background" style="max-width: 600px;">
//     <%= select_tag 'state', options_from_collection_for_select(States.abbreviations, :to_s, :upcase),
//                    {:prompt => t('.select_state'), class: 'form-control js-stateSelect notranslate'} %>
//     <select class="form-control js-citySelect dn mtm notranslate"></select>
//     <select class="form-control js-schoolSelect mtm dn notranslate"></select>
//   </div>
// </div>
// )
// }

// }