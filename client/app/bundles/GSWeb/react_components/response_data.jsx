import React, { PropTypes } from 'react';

export default class ResponseData extends React.Component {

  static propTypes = {
    input: PropTypes.arrayOf(PropTypes.shape({
      response_key: PropTypes.string.isRequired,
      response_value: PropTypes.arrayOf(PropTypes.string).isRequired
    })).isRequired,
    limit: PropTypes.number
  };

  static defaultProps = {
    limit: 0
  }

  constructor(props) {
    super(props);
    this.showMore = this.showMore.bind(this);
    this.state = {
      limit: props.limit
    }
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.limit != this.props.limit) {
      this.setState({
        limit: nextProps.limit
      });
    }
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

  showMore() {
    this.setState({ limit: 0 })
  }

  render() {
    let data = this.props.input;
    if (this.state.limit > 0) {
      data = data.slice(0, this.state.limit);
    }
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
          <div className="col-xs-12 col-sm-6">
            <ul>
              {this.listOfAnswers(response_key, answers)}
              { this.state.limit > 0 && index == (this.state.limit - 1) && <a href="javascript:void(0);" onClick={this.showMore}>Show more</a> }
            </ul>
          </div>
        </div>);
      }
    });


    return (<div>
      {responses}
    </div>
    )
  }

}
