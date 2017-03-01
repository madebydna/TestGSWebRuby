import React, { PropTypes } from 'react';
import validations from '../components/validations';

export default class ValidatingInput extends React.Component {
  static propTypes = {
    validation: React.PropTypes.string
  };

  constructor(props) {
    super(props);
    this.onChange = this.onChange.bind(this);
    this.state = {
      errors: []
    };
  }

  onChange(event) {
    let value = event.target.value;
    let errors = validations[this.props.validation](value);

    this.setState({
      errors: errors
    }, () => {
      if(errors.length == 0 && this.props.onChange) {
        this.props.onChange(event);
      }
    })
  }

  componentDidUpdate(prevProps, prevState) {
    if(prevState.errors.length === 0 && this.state.errors.length > 0 && this.props.onInvalid) {
      this.props.onInvalid();
    } else if(prevState.errors.length > 0 && this.state.errors.length === 0 && this.props.onValid) {
      this.props.onValid();
    }
  }

  inputProps() {
    this.props;
  }

  renderError() {
    return <span className="errors">
      <ul>
        {this.state.errors.map(e => <li>{e}</li>)}
      </ul>
    </span>
  }

  render() {
    const {
      validation,
      onChange,
      onValid,
      onInvalid,
      ...rest
    } = this.props;

    return <span>
      <input {...rest} onChange={this.onChange}></input>
      { this.state.errors.length > 0 && this.renderError() }
    </span>
  }
}
