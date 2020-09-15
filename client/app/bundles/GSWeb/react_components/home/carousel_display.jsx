import React from "react";
import PropTypes from "prop-types";
import { XS } from "util/viewport";
import { animated } from "react-spring";
import useTransitions from "react_components/hooks/use_transitions";

const CarouselDisplay = ({ type, size, index, direction, slideshowUrls, callback }) => {

  let transitions;
  const slideshows = slideshowUrls.map((url, idx) => ({id: idx, url}))
  const transitionGoingLeft = useTransitions(slideshows[index]);
  const transitionGoingRight = useTransitions(slideshows[index], {
    from: { transform: "translate3d(-100%,0,0)" },
    enter: { transform: "translate3d(0%,0,0)" },
    leave: { transform: "translate3d(100%,0,0)" },
  });
  const styles = {
    position: "absolute",
    width: "100%",
    height: "100%",
    backgroundRepeat: "no-repeat",
    backgroundSize: "contain",
  };

  const translateRight = () => {
    if(type == 'large' && size == XS){
      callback()
    }
  }

  if (direction == "right") {
    transitions = transitionGoingRight
  }else{
    transitions = transitionGoingLeft
  }

  return (
    <span className={`carousel-display-${type}`}>
      {transitions.map(({ item, props, key }) => {
        return (
          <animated.div
            key={key}
            onClick={translateRight}
            style={{
              ...props,
              ...styles,
              backgroundImage: `url(${item.url})`,
            }}
          ></animated.div>
        );
      })}
    </span>
  );
};

CarouselDisplay.propTypes = {
  type: PropTypes.string,
  size: PropTypes.number,
  index: PropTypes.number,
  direction: PropTypes.string,
  slideshowUrls: PropTypes.arrayOf(PropTypes.string),
  callback: PropTypes.func
};

export default CarouselDisplay;
