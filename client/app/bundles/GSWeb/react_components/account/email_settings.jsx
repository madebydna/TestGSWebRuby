import React from 'react';
import PropTypes from 'prop-types';
import { addSubscription, deleteSubscription } from 'api_clients/subscriptions';

const checkbox = ({ id, list, checked }) => (
  <input
    type="checkbox"
    name={list}
    defaultChecked={checked}
    onChange={event =>
      event.target.checked ? addSubscription(list) : deleteSubscription(id)
    }
    className={`js-delete-subscription-${id}`}
    value={`/gsr/user/subscriptions/${id}/`}
  />
);

const shouldGroupList = list =>
  list === 'mystat' ||
  list === 'mystat_private' ||
  list === 'mystat_unverified';

const EmailSettings = ({ subscriptions }) => {
  const subscriptionIncludesGreatNews =
    subscriptions.filter(sub => sub.list === 'greatnews').length > 0;
  const subscriptionIncludesSponsor =
    subscriptions.filter(sub => sub.list === 'sponsor').length > 0;
  const subscriptionIncludesMyStat =
    subscriptions.filter(sub => sub.list === 'mystat').length > 0;
  const subscriptionIncludesMyStatPrivate =
    subscriptions.filter(sub => sub.list === 'mystat_private').length > 0;
  const subscriptionIncludesMyStatUnverified =
    subscriptions.filter(sub => sub.list === 'mystat_unverified').length > 0;

  let lastList = null;
  return (
    <div>
      {
        <div className="body mtl">
          {subscriptions.map(subscription => {
            const content = (
              <div className="pbl" key={subscription.id}>
                {!shouldGroupList(subscription.list) && (
                  <div className="fl mtn prm">
                    {checkbox({ ...subscription, checked: true })}
                  </div>
                )}
                {lastList !== subscription.list && (
                  <React.Fragment>
                    <h3>{subscription.longName}</h3>
                    <div>{subscription.description}</div>
                  </React.Fragment>
                )}
                {shouldGroupList(subscription.list) && (
                  <div className={`js-subscription-${subscription.id}`}>
                    <div className="open-sans_b mtm">
                      <label className="pointer notranslate">
                        <div className="fl mtn prm">
                          {checkbox({ ...subscription, checked: true })}
                        </div>
                        {subscription.schoolName}, {subscription.schoolCity},{' '}
                        {subscription.schoolState}
                      </label>
                    </div>
                  </div>
                )}
              </div>
            );
            lastList = subscription.list;
            return content;
          })}

          {!subscriptionIncludesGreatNews && (
            <div className="js-subscription">
              <label className="db pointer">
                <div className="fl mtn prm">
                  {checkbox({ list: 'greatnews', checked: false })}
                </div>
                <h3>Weekly newsletter</h3>
              </label>
              <div>
                The tips and tools you need to make smart choices about your
                child&apos;s education.
              </div>
            </div>
          )}

          {!subscriptionIncludesSponsor && (
            <div>
              <label className="db pointer">
                <div className="fl mtn prm">
                  {checkbox({ list: 'sponsor', checked: false })}
                </div>
                <h3>Partner offers</h3>
              </label>
              <div>
                Receive valuable offers and information from GreatSchools&apos;
                partners.
              </div>
            </div>
          )}

          {!subscriptionIncludesMyStat &&
            !subscriptionIncludesMyStatPrivate &&
            !subscriptionIncludesMyStatUnverified && (
              <div>
                <h3>My School Stats</h3>
                <div>
                  Follow schools to save them here and we&apos;ll update you
                  when there are new reviews, test scores, or GreatSchools
                  ratings.
                </div>
              </div>
            )}
        </div>
      }
    </div>
  );
};

EmailSettings.propTypes = {
  subscriptions: PropTypes.arrayOf(PropTypes.object)
};

export default EmailSettings;
