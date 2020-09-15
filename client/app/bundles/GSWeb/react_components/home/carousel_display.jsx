import React, { useEffect } from "react";
import PropTypes from "prop-types";
import { useTransition, animated, config } from "react-spring";

const CarouselDisplay = ({ type, size, index, direction, slideshowUrls }) => {

  const slideshows = slideshowUrls.map((url, idx) => ({id: idx, url}))

  const transitionGoingLeft = useTransition(
    slideshows[index],
    (item) => item.id,
    {
      from: { transform: "translate3d(100%,0,0)" },
      enter: { transform: "translate3d(0%,0,0)" },
      leave: { transform: "translate3d(-100%,0,0)" },
      config: config.stiff,
    }
  );
  const transitionGoingRight = useTransition(
    slideshows[index],
    (item) => item.id,
    {
      from: { transform: "translate3d(-100%,0,0)" },
      enter: { transform: "translate3d(0%,0,0)" },
      leave: { transform: "translate3d(100%,0,0)" },
      config: config.stiff,
    }
  );

  if (direction == "right") {
    return (
      <span className={`carousel-display-${type}`}>
        {transitionGoingRight.map(({ item, props, key }) => {
          return (
            <animated.div
              key={key}
              style={{
                ...props,
                position: "absolute",
                backgroundImage: `url(${item.url})`,
                width: "100%",
                height: "100%",
                backgroundRepeat: "no-repeat",
                backgroundSize: "contain",
              }}
            ></animated.div>
          );
        })}
      </span>
    );
  } else {
    return (
      <span className={`carousel-display-${type}`}>
        {transitionGoingLeft.map(({ item, props, key }) => {
          return (
            <animated.div
              key={key}
              style={{
                ...props,
                position: "absolute",
                backgroundImage: `url(${item.url})`,
                width: "100%",
                height: "100%",
                backgroundRepeat: "no-repeat",
                backgroundSize: "contain",
              }}
            ></animated.div>
          );
        })}
      </span>
    );
  }
};

export default CarouselDisplay;
