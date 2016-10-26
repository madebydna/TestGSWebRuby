var GS = GS || {};

// Has methods for formatting cached test score data
GS.testScoresHelpers = {
  flatten: function(hierarchicalDataForDataType) {
    var array = [];
    _.forOwn(
      hierarchicalDataForDataType,
      (obj, breakdown) => _.forOwn(obj.grades,
        (obj, grade) => _.forOwn(obj.level_code,
          (obj, level_code) => _.forOwn(obj,
            (obj, subject) => _.forOwn(obj,
              (obj, year) => array.push(
                _.merge(
                  {}, obj, {
                    breakdown: breakdown,
                    grade: grade,
                    level_code: level_code,
                    subject: subject,
                    year: year
                  }
                )
              )
            )
          )
        )
      )
    )
    return array;
  },

  // filters array of data, given a criteria object that contains
  // key:values to match against
  filter: function(flattenedTestScoreDataArray, criteria) {
    return _.where(flattenedTestScoreDataArray, criteria);
  },

  incomeLevelTestScoreData : function(testScoreDataArray) {
    return _.filter(testScoreDataArray, obj =>
        _.include(
          ['Economically disadvantaged', 'Not economically disadvantaged'],
          obj.breakdown
        )
    );
  },

  testDataMatchingEthnicities(
    testScoreDataArray,
    arrayOfEthnicityCharacteristicsObjects) {

    let testScoreBreakdownsToEthnicityBreakdowns = {
      'African American': 'Black'
    };

    testScoreDataArray = _.map(
      testScoreDataArray, obj => _.merge(
        {}, obj, {
          breakdown: testScoreBreakdownsToEthnicityBreakdowns[obj.breakdown] || obj.breakdown
        }
      )
    )

    let ethnicities = _.map(
      arrayOfEthnicityCharacteristicsObjects,
      obj => obj.breakdown
    );
    ethnicities.push('All');

    return _.select(
      testScoreDataArray, obj => _.include(ethnicities, obj.breakdown)
    );
  }

};

