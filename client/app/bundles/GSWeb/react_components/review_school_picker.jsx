import React from "react";
import ReviewPageAlternateSelector from "./review_page_alternate_selector";
import ReviewPageSearchBox from "./review_page_search_box";

export default class ReviewSchoolPicker extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      autoCompleteActive: true
    }
  }
  showStateSelector = () => {
    this.setState({autoCompleteActive: false});
  }

  render() {
    return (
        this.schoolSelectorObject()
    )
  }

  schoolSelectorObject() {
    if (this.state.autoCompleteActive) {
      return (
          <ReviewPageSearchBox
              osp={this.props.osp}
              resultTypes={this.props.resultTypes}
              showSearchAllOption={this.props.showSearchAllOption}
              showSearchButton={this.props.showSearchButton}
              showStateSelector={this.showStateSelector} />
      )
    }
    else {
      return <ReviewPageAlternateSelector osp={this.props.osp} />;
    }
  }
}