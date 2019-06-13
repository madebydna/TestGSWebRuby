import React from 'react';
import { links } from '../components/links';
import { t } from '../util/i18n';

const QualarooDistrictLink = ({ module, state, districtId }) => 
    <div className="module_feedback">
        <a href={`${links.qualaroo[module]}?state=${state}&districtId=${districtId}`} className="anchor-button" target="_blank" rel="nofollow">
        {t('search_help.send_feedback')}
        </a>
    </div>

export default QualarooDistrictLink;