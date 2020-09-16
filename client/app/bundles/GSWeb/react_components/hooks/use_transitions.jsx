import { useTransition, config } from "react-spring";
import PropTypes from "prop-types";

const useTransitions = (item, configs) => {
  const initialProps = {
    from: { transform: "translate3d(100%,0,0)" },
    enter: { transform: "translate3d(0%,0,0)" },
    leave: { transform: "translate3d(-100%,0,0)" },
    config: config.stiff,
  };

  return useTransition(item, (item) => item.id, {...initialProps, ...configs});
}

useTransitions.propTypes = {
  initalProps: PropTypes.object
};

useTransitions.defaultProps = {
  configs: {},
};


export default useTransitions;