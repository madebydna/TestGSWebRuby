import React from 'react';
import PropTypes from 'prop-types';

const size = 10;
const radCircumference = Math.PI * 2;
const center = size / 2;
const radius = center - 1; // padding to prevent clipping

function renderPaths(slices) {
  const total = slices.reduce((totalValue, { value }) => totalValue + value, 0);

  let radSegment = 0;
  let lastX = radius;
  let lastY = 0;

  return slices.map(({ color, value }, index) => {
    if (value === total) {
      return (
        <circle
          r={radius}
          cx={center}
          cy={center}
          fill={color}
          key={index}
        />
      );
    }

    if (value === 0) {
      return;
    }

    const valuePercentage = value / total;

    // if percentage is greater than 50%, need a longer arc
    const longArc = (valuePercentage <= 0.5) ? 0 : 1;

    radSegment += valuePercentage * radCircumference;
    const nextX = Math.cos(radSegment) * radius;
    const nextY = Math.sin(radSegment) * radius;

    // d is a string that describes the path of the slice.
    // The weirdly placed minus signs [eg, (-(lastY))] are due to the fact
    // that our calculations are for a graph with positive Y values going up,
    // but on the screen positive Y values go down.
    const d = [
      `M ${center},${center}`,
      `l ${lastX},${-lastY}`,
      `a${radius},${radius}`,
      '0',
      `${longArc},0`,
      `${nextX - lastX},${-(nextY - lastY)}`,
      'z',
    ].join(' ');

    lastX = nextX;
    lastY = nextY;

    return <path d={d} fill={color} key={index} />;
  });
}

class PieChart extends React.Component {
  render() {
    const border = this.props.borderWidth > 0 ? (
      <circle
        cx={center}
        cy={center}
        r={radius}
        stroke={this.props.borderColor}
        strokeWidth={this.props.borderWidth}
        fill='transparent'
      />
    ) : null;

    return (
      <svg viewBox={`0 0 ${size} ${size}`} height="100px">
        <g transform={`rotate(-90 ${center} ${center}) translate(0, ${size}) scale(1, -1)`}>
          {renderPaths(this.props.slices)}
        </g>
        {border}
      </svg>
    );
  }
}

PieChart.propTypes = {
  slices: PropTypes.arrayOf(PropTypes.shape({
    color: PropTypes.string.isRequired, // hex color
    value: PropTypes.number.isRequired,
  })).isRequired,
  borderColor: PropTypes.string,
  borderWidth: PropTypes.number,
};

PieChart.defaultProps = {
  borderColor: '#000',
  borderWidth: 0
};
export default PieChart;
