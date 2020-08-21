import React from 'react';
import PropTypes from "prop-types";
import DataModule from "react_components/data_module";
import Spending from "react_components/icons/spending";

class LowIncomeDataModule extends DataModule {
  icon(){
    return (
      <div className="circle-rating--equity-blue">
        <Spending innerCircleColor={"#cae3f3"} />
      </div>
    );
  }
}

export default LowIncomeDataModule;