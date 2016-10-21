class Equity extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      equityContent: this.initializeEquity()
    }
  }

  render() {
    console.log("Love Love Love 1");
    var tabSets = [];
    for (var i = 0; i < this.state.equityContent.length; i++) {
      tabSets.push(<Tabs
          tabs={ this.state.equityContent[i] }
      />)
    }
    return (
        <div>
          <a name="Equity"></a>
          { tabSets }
          {/*<Tabs*/}
            {/*tabs={ this.state.equityContent[0] }*/}
        {/*/>*/}
        </div>
    );
  }

  initializeEquity() {
    // console.log("Love Love Love 2");
    return JSON.parse(JSON.stringify(this.props.equity));
  }
};

// Equity.propTypes = {
//   equity: React.PropTypes.arrayOf(React.PropTypes.object({
//     tab_name: React.PropTypes.string,
//     content: React.PropTypes.object
//   }))
// };


<div>
  #equity.test_scores_by_ethnicity.to_json

</div>