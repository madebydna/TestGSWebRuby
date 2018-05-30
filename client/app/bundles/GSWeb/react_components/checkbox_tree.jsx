import React from 'react';
import PropTypes from 'prop-types';
import { uniq } from 'lodash';

const makeTree = nodes => {
  const parent = node => nodes.find(o => o.key === node.parentKey);
  const children = (node, filter = () => true) =>
    nodes.filter(o => o.parentKey === node.key).filter(filter);

  const parentAsArray = node => (parent(node) ? [parent(node)] : []);

  const ancestors = node =>
    node ? parentAsArray(node).concat(ancestors(parent(node))) : [];

  const descendants = node =>
    children(node).concat(
      children(node).reduce(
        (accum, child) => accum.concat(descendants(child)),
        []
      )
    );

  const anyChild = (node, func) => children(node).some(func);
  const allChildren = (node, func) => children(node).every(func);

  return {
    parent,
    children,
    ancestors,
    descendants,
    anyChild,
    allChildren
  };
};

const CheckboxTree = ({ options, activeOptions, onChange, children }) => {
  const tree = makeTree(options);

  const removeAll = (originalArray, array) =>
    originalArray.filter(o => array.indexOf(o) === -1);

  const isSelected = option => activeOptions.indexOf(option.key) > -1;
  const notSelected = option => !isSelected(option);

  const optionsForKeys = keys => options.filter(o => keys.indexOf(o.key) > -1);

  const deselectOption = option =>
    removeAll(
      optionsForKeys(activeOptions),
      tree
        .ancestors(option)
        .filter(ancestor =>
          tree.allChildren(ancestor, o => o === option || notSelected(o))
        )
        .concat([option])
        .concat(tree.descendants(option))
    );

  const selectOption = option =>
    optionsForKeys(activeOptions)
      .concat(tree.ancestors(option))
      .concat([option])
      .concat(tree.descendants(option))
      .filter(o => !!o);

  const handleToggle = option =>
    isSelected(option)
      ? onChange(uniq(deselectOption(option).map(o => o.key)))
      : onChange(uniq(selectOption(option).map(o => o.key)));

  return children(
    options.map(option => ({
      option,
      active: isSelected(option),
      select: () => handleToggle(option)
    }))
  );
};

const optionPropTypes = PropTypes.shape({
  key: PropTypes.node,
  label: PropTypes.node,
  parentKey: PropTypes.node
});

CheckboxTree.propTypes = {
  options: PropTypes.arrayOf(optionPropTypes).isRequired,
  activeOptions: PropTypes.arrayOf(optionPropTypes),
  onChange: PropTypes.func.isRequired,
  children: PropTypes.func.isRequired
};

CheckboxTree.defaultProps = {
  activeOptions: []
};

export default CheckboxTree;
