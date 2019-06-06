import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import School from 'react_components/search/school';
import LoadingOverlay from 'react_components/search/loading_overlay';
import CompareSchoolTableRow from './compare_school_table_row';
import SchoolTableColumnHeader from 'react_components/search/school_table_column_header';
import CompareContext from './compare_context';
import { keepInViewport } from 'util/sticky';

class CompareSchoolTable extends React.Component {
  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
    isLoading: PropTypes.bool,
    compareTableHeaders: PropTypes.array,
    tableView: PropTypes.string
  };

  static defaultProps = {
    isLoading: false,
    tableView: 'Overview',
    compareTableHeaders: {}
  };

  constructor(props) {
    super(props);
    this.headers = React.createRef();
  };

  componentDidMount(){
    keepInViewport(this.headers, {
      initialTop: 162,
      setTop: true,
      setBottom: false
    });
  }

  tableHeaders(headerArray = [], sort) {
    const schoolHeader = [
      <SchoolTableColumnHeader
        key={`school`}
        colName={capitalize(t('school'))}
        classNameTH={['name', 'distance', 'rating'].includes(sort) ? 'school highlight' : 'school'}
        tooltipContent=""
      />
    ];
    let headers = headerArray.map(hash => (
      <SchoolTableColumnHeader
        key={hash.key}
        colName={hash.title}
        classNameTH={hash.className}
        tooltipContent={hash.tooltip}
      />
    ));
    headers = schoolHeader.concat(headers);
    return (
      <thead>
      <tr>{headers}</tr>
      </thead>
    );
  };

  renderCompareSchoolTable(){
    let {schools, isLoading, compareTableHeaders} = this.props;
    const pinnedSchool = schools.filter(s => s.pinned)[0];
    const otherSchools = schools.filter(s => !s.pinned);
    return (
      <CompareContext.Consumer>
        {({sort, breakdown, size}) =>
          <section className="school-table">
            {
              /* would prefer to just not render overlay if not showing it,
               but then loader gif has delay, and we would need to preload it */
              <LoadingOverlay
                visible={isLoading && schools.length > 0}
                numItems={schools.length}
              />
            }
            <div className={isLoading ? 'loading' : undefined}>
              <table>
                {this.tableHeaders(compareTableHeaders, sort)}
                <tbody>
                <CompareSchoolTableRow
                  columns={compareTableHeaders}
                  key={pinnedSchool.state + pinnedSchool.id} {...pinnedSchool}
                  breakdown={breakdown}
                  size={size}
                />
                {otherSchools.map(s => (
                  <CompareSchoolTableRow
                    columns={compareTableHeaders}
                    key={s.state + s.id}
                    sort={sort}
                    breakdown={breakdown}
                    size={size}
                    {...s}
                  />
                ))}
                </tbody>
              </table>
            </div>
          </section>
        }
      </CompareContext.Consumer>
    )
  }

  render() {
    return this.renderCompareSchoolTable();
  };
};

export default CompareSchoolTable;
