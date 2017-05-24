import React, { PropTypes } from 'react';

export default class ResponseData extends React.Component {

  static propTypes = {
    input: PropTypes.array
  };

  constructor(props) {
    super(props);
  }

  render() {
    let data = this.props.input;
    let responses = data.map((thing) => {
      let response_key = thing.response_key;
      let answers = thing.response_value;
      if (response_key == '') {
        return (<div className="response clearfix">
          <p>{answers.join(', ')}</p>
        </div>);
      }
      else {
        return (<div className="response clearfix">
          <div className="col-xs-12 col-sm-4 sources-text" key={response_key}>{response_key}</div>
          <div className="col-xs-12 col-sm-6">{answers.join(', ')}</div>
        </div>);
      }
    });
    return (<div>
      {responses}
    </div>
    )
  }

}