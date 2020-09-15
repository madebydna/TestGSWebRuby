import React, { useEffect, useState, useCallback } from "react";
import PropTypes from "prop-types";
import { useTransition, animated } from "react-spring";
import { t } from "util/i18n";

const Card = ({ index, slideshowUrls, direction }) => {

  const slideshows = slideshowUrls.map((url, idx) => ({
    id: idx,
    url,
    header: t(`slideshows.headers.${idx}`),
    subtext: t(`slideshows.subtexts.${idx}`),
    links: t(`slideshows.links.${idx}`),
  }));

  const transitionFlippingUp = useTransition(
    slideshows[index],
    (item) => item.id,
    {
      from: { transform: "translate3d(0, 25%,0)" },
      enter: { transform: "translate3d(0,0,0)" },
      leave: { transform: "translate3d(0,-100%,0)", opacity: 0 },
      config: { mass: 5, tension: 500, friction: 80 },
    }
  );

  const transitionFlippingDown = useTransition(
    slideshows[index],
    (item) => item.id,
    {
      from: { transform: "translate3d(0,-25%,0)" },
      enter: { transform: "translate3d(0,0,0)" },
      leave: { transform: "translate3d(0,100%,0)", opacity: 0 },
      config: { mass: 5, tension: 500, friction: 80 },
    }
  );

  if (direction == "right") {
    return(
      <div>
        {
          transitionFlippingUp.map(({ item, props, key }) => {
            return (
              <animated.div
                key={key}
                style={{
                  ...props,
                  position: 'absolute',
                  overflow: 'hidden'
                }}
              >
                <h3>{`${item.header}`}</h3>
                <p>
                  {`${item.subtext}`}
                  <br />
                  <br />
                  <a href="/" className="primary-button">
                    Learn More
                  </a>
                </p>
              </animated.div>
            );
          })
        }
      </div>
    )
  } else {
    return(
      <div>
        {
          transitionFlippingDown.map(({ item, props, key }) => {
            return (
              <animated.div
                key={key}
                style={{
                  ...props,
                  position: "absolute",
                  overflow: "hidden",
                }}
              >
                <h3>{`${item.header}`}</h3>
                <p>
                  {`${item.subtext}`}
                  <br />
                  <br />
                  <a href="/" className="primary-button">
                    Learn More
                  </a>
                </p>
              </animated.div>
            );
          })
        }
      </div>
    )
  }
};

export default Card;