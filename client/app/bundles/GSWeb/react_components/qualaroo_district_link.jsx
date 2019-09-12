import React from 'react';
import { links } from '../components/links';
import { t } from '../util/i18n';

const QualarooDistrictLink = ({ module, state, districtId, type }) => {
    const linkType = type || 'feedback';
    if (linkType =='feedback'){
        return (
            <div className="module_feedback">
                <a href={`${links.qualaroo[module]}?state=${state}&districtId=${districtId}`} className="anchor-button" target="_blank" rel="nofollow">
                {t('search_help.send_feedback')}
                </a>
            </div>
        )
    } else {
        return (
            <div className="module_feedback">
                {t('was_this_useful')}
                <a href={`${links.qualaroo[module]}?state=${state}&districtId=${districtId}&a=0`} className="anchor-button" target="_blank" rel="nofollow">
                    {t('yes')}
                </a>
                <a href={`${links.qualaroo[module]}?state=${state}&districtId=${districtId}&a=1`} className="anchor-button" target="_blank" rel="nofollow">
                    {t('no')}
                </a>
            </div>
        )
    }
}
export default QualarooDistrictLink;