import React from "react";
import PropTypes from "prop-types";
import { animated } from "react-spring";
import { XS } from "util/viewport";
import useTransitions from "react_components/hooks/use_transitions";
import { t } from "util/i18n";

const cardStyles = {
  position: "absolute",
  overflow: "hidden",
  padding: "0 5px 5px 0",
  marginTop: '40px'
};

const Card = ({ index, slideshowUrls, direction, size }) => {
  let transitions;
  const slideshows = slideshowUrls.map((url, idx) => ({
    id: idx,
    url,
    header: t(`slideshows.headers.${idx}`),
    subtext: t(`slideshows.subtexts.${idx}`),
    link: t(`slideshows.links.${idx}`),
  }));

  const transitionTranslatingUp = useTransitions(slideshows[index], {
    from: { transform: `translate3d(0, ${size == XS ? '-5%' : '-25%'},0)` },
    enter: { transform: "translate3d(0,0,0)" },
    leave: { transform: "translate3d(0,100%,0)", opacity: 0 },
    config: { mass: 5, tension: 500, friction: 80 },
  });

  const transitionTranslatingDown = useTransitions(slideshows[index], {
    from: { transform: `translate3d(0,25%,0)` },
    enter: { transform: "translate3d(0,0,0)" },
    leave: { transform: "translate3d(0,-100%,0)", opacity: 0 },
    config: { mass: 5, tension: 500, friction: 80 },
  });

  const cardModule = (item) => {
    return(
      <React.Fragment>
        <h3>{`${item.header}`}</h3>
        <p>
          {`${item.subtext}`}
          <br />
          <br />
          <a href={`${item.link}`} className="primary-button">
            {t('slideshows.Learn more')}
          </a>
        </p>
      </React.Fragment>
    )
  }

  if (direction == 'right'){
    transitions = transitionTranslatingUp;
  }else{
    transitions = transitionTranslatingDown;
  }

    return (
      <div>
        {transitions.map(({ item, props, key }) => {
          return (
            <animated.div
              key={key}
              style={{
                ...props,
                ...cardStyles,
              }}
            >
              {cardModule(item)}
            </animated.div>
          );
        })}
      </div>
    );
};

Card.propTypes = {
  index: PropTypes.number,
  slideshowUrls: PropTypes.arrayOf(PropTypes.string),
  direction: PropTypes.string,
  size: PropTypes.number
};

export default Card;