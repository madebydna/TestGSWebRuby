import React from 'react';
import DataModule from '../data_module';
import InfoBox from '../school_profiles/info_box';
import QualarooDistrictLink from '../qualaroo_district_link';
import { t } from '../../util/i18n';

class AcademicsDataModule extends DataModule {
  
  constructor(props) {
    super(props);
  }

  renderQualarooDistrictLink(pageType) {
    if (pageType === 'district') {
      return (
        <QualarooDistrictLink module='district_academics' state={this.props.locality.stateShort} districtId={this.props.locality.district_id} />
      );
    }
  }

  defaultFooter() {
    return (
      <div data-ga-click-label={this.props.title}>
        <InfoBox content={this.props.sources} element_type="sources" pageType={this.props.pageType}>{t('See notes')}</InfoBox>
        {this.renderQualarooDistrictLink(this.props.pageType)}
      </div>
    );
  }
}

export default AcademicsDataModule;