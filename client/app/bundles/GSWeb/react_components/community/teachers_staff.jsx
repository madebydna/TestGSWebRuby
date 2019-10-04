import React from 'react';
import { t } from "util/i18n";
import BasicDataModuleLayout from '../school_profiles/basic_data_module_layout';
import QualarooDistrictLink from '../qualaroo_district_link';
import Drawer from '../drawer';
import { XS } from '../../util/viewport';
import Sources from './teachers_staff/sources';
import DataRow from './teachers_staff/data_row';
import OtherStaffTable from './teachers_staff/other_staff_table';

class TeachersStaff extends React.Component {

  openLabel(){
    return this.props.size > XS ? `${t('Show less')} ${t('teachers_staff.module_title')}` : t('Show less');
  }

  closedLabel(){
    return this.props.size > XS ? `${t('Show more')} ${t('teachers_staff.module_title')}` : t('Show more');
  }

  renderTitle() {
    return (
      <div  data-ga-click-label={t('teachers_staff.module_title')}>
        <h3>{t('teachers_staff.module_title')}</h3>
      </div>
    )
  }

  renderContent() {
    return (<React.Fragment>
      {this.props.data.main_staff.map((item, index) => {
        return <DataRow {...item} key={`ts_row_${index}`} />
      })}
      <div className="rating-container__more-items">
        <Drawer
          content={<OtherStaffTable {...this.props.data.other_staff} />}
          closedLabel={this.closedLabel()}
          openLabel={this.openLabel()}
        />
      </div>
    </React.Fragment>)
  }

  renderIcon() {
    return (
      <div className="circle-rating--equity-blue">
        <span className="icon-user"></span>
      </div>
    )
  }

  renderFooter() {
    return (
      <div data-ga-click-label={this.props.title}>
        <Sources sources={this.props.data.sources} />
        <QualarooDistrictLink module='district_teacher_staff' 
          districtId={this.props.data.district_id} state={this.props.data.state} type='yes_no' />
      </div>
    )
  }

  render() {
    return(
      <BasicDataModuleLayout 
        id="teachers-staff"
        className="teachers-staff"
        icon={this.renderIcon()}
        title={this.renderTitle()}
        subtitle={t('teachers_staff.module_subtitle')}
        csa_badge={false}
        body={this.renderContent()}
        footer={this.renderFooter()}
        />
    )
  }
}

export default TeachersStaff;