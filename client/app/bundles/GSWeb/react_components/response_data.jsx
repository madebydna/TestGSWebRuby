import React, { PropTypes } from 'react';

export default class ResponseData extends React.Component {

  static propTypes = {
    input: PropTypes.arrayOf(PropTypes.shape({
      response_key: PropTypes.string.isRequired,
      response_value: PropTypes.arrayOf(PropTypes.string).isRequired
    })).isRequired
  };

  constructor(props) {
    super(props);
  }

  listOfAnswers(response_key, answers) {
    let styling = {};
    if (answers[0] == 'Data not provided by the school' || answers[0] == 'Datos no provistos por la escuela') {
      styling = {color: 'slategray'};
    }
    return answers.map((answer, index) => {
      if(response_key == 'Admissions webpage' || response_key == 'Página de admisiones' || response_key == 'Additional info') {
        let answerHref = answer.trim();
        if (!(answerHref.startsWith('http') || answerHref.startsWith('https'))) {
          answerHref = 'http://' + answerHref;
        }
        answer = <a target="_blank" href={answerHref}>{answer}</a>;
        styling.wordWrap = 'break-word';
      }
      if(answers.length > 1) {
        return <li style={styling} style={{listStyle: 'disc'}} key={index}>{answer}</li>
      } else {
        return <li style={styling} key={index}>{answer}</li>
      }
    });
  }

  render() {
    let data = this.props.input;
    let responses = data.map((thing, index) => {
      let response_key = thing.response_key;
      let answers = thing.response_value;
      if (response_key == '') {
        return (<div className="response clearfix" key={index}>
          <p>{answers.join(', ')}</p>
        </div>);
      }
      else {
        return (<div className="response clearfix" key={index}>
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
