class EquityContentPane extends React.Component {

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="row">
        <div className="col-xs-12 col-sm-6">{this.props.graph}</div>
        <div className="col-xs-12 col-sm-6">{this.props.text}</div>
      </div>
    )
  }
}

EquityContentPane.propTypes = {
  graph: React.PropTypes.object.isRequired,
  text: React.PropTypes.string.isRequired
}
