import React, { PropTypes } from 'react';

export default class ShortenText extends React.Component {

  static propTypes = {
    text: React.PropTypes.string.isRequired,
    length: React.PropTypes.number.isRequired
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

  renderShortenedText() {
    return(
      <span>
        { this.shortenText(this.props.text, this.props.length) }
        <span onClick={this.showFullText}>... <a href="javascript:void(0);">More</a></span>
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
