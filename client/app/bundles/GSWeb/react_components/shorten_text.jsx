import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../util/i18n';
import ForwardArrowBlue from 'icons/forward_arrow_blue.png';

export default class ShortenText extends React.Component {

  static propTypes = {
    text: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    label: PropTypes.string,
    renderDownArrow: PropTypes.bool
  };

  constructor(props) {
    super(props);
    this.state = {
      showFullText: false
    }
    this.showFullText = this.showFullText.bind(this);
  }

  showFullText() {
    this.setState({ showFullText: true });
  }

  renderLabel () {
    return this.props.label || t('More');
  }

  renderDownArrow() {
    if (this.props.renderDownArrow) {
      return (
        <img src={ForwardArrowBlue} className="see-more-arrow" />
      );
    }
  }

  renderShortenedText() {
    return(
      <span>
        { this.shortenText(this.props.text, this.props.length) }
        <span onClick={this.showFullText}>... <a href="javascript:void(0);">{this.renderLabel()}&nbsp;{this.renderDownArrow()}</a></span>
      </span>
    )
  }

  renderFullText() {
    return(<span>{ this.props.text }</span>)
  }

  render() {
    if(this.props.text.length <= this.props.length || this.state.showFullText) {
      return this.renderFullText();
    } else {
      return this.renderShortenedText();
    }
  }

  shortenText(text, length) {
    let pos = text.indexOf(' ', length);
    if(pos == -1) return text;
    return text.substring(0, pos);
  }
}
