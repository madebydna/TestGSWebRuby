class EquityContentPane extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      // active: this.props.active
    }
  }
  get_narrative(){
    return {__html: this.props.text.props.children}
  }

  render() {
    return(
      <div className="row">
        <div className="col-xs-12 col-sm-6">{this.props.graph}</div>
        <div className="col-xs-12 col-sm-6">
          <div className="right_content" dangerouslySetInnerHTML={this.get_narrative()}  />
        </div>
      </div>
    )
  }
}

EquityContentPane.propTypes = {
  graph: React.PropTypes.object.isRequired,
  text: React.PropTypes.element.isRequired
};
