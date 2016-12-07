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
                    year: year,
                    school_value: obj.score
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

    let ethnicities = _.map(
      arrayOfEthnicityCharacteristicsObjects,
      obj => obj.original_breakdown
    );

    ethnicities.push('All');
    ethnicities.push('All students');

    let result = _.select(
      testScoreDataArray, obj => _.include(ethnicities, obj.breakdown)
    );
    return result;
  }
};
