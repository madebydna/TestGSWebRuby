import React from 'react';
import DataModule from '../data_module';
import InfoBox from '../school_profiles/info_box';
import { t } from '../../util/i18n';

class AcademicsDataModule extends DataModule {
  
  constructor(props) {
    super(props);
  }

  defaultFooter() {
    return (
      <div data-ga-click-label={this.props.title}>
        <InfoBox content={this.props.sources} element_type="sources" pageType={this.props.pageType}>{t('See notes')}</InfoBox>
      </div>
    );
  }
}

export default AcademicsDataModule;