import React, { PropTypes } from 'react';

export default class ResponseData extends React.Component {

  static propTypes = {
    input: PropTypes.array
  };

  constructor(props) {
    super(props);
  }

  listOfAnswers(response_key, answers) {
    let styling;
    if (answers[0] == 'Data not provided by the school' || answers[0] == 'Datos no provistos por la escuela') {
      styling = {color: 'slategray'};
    }
    return answers.map((answer) => {
      if(response_key == 'Admissions webpage' || response_key == 'Página de admisiones') {
        answer = <a href={answer}>{answer}</a>;
      }
      if(answers.length > 1) {
        return <li style={styling} style={{listStyle: 'disc'}}>{answer}</li>
      } else {
        return <li style={styling}>{answer}</li>
      }
    });
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
          <div className="col-xs-12 col-sm-6"><ul>{this.listOfAnswers(response_key, answers)}</ul></div>
        </div>);
      }
    });
    return (<div>
      {responses}
    </div>
    )
  }

}
