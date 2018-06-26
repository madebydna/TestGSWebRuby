import React from 'react';
import PropTypes from 'prop-types';
import { difference, uniq } from 'lodash';

const makeTree = nodes => {
  // node.parentKey is implementation-specific and limits reuse
  const parent = node => nodes.find(o => o.key === node.parentKey);
  const children = (node, filter = () => true) =>
    nodes.filter(o => o.parentKey === node.key).filter(filter);

  // there's only one parent. But sometimes I want it as an array to make
  // some array concatentation code easier. If parent is null, then I
  // want empty array
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

// A tree of Selectables
const SelectableTree = ({
  options,
  activeOptions,
  onChange,
  children,
  noneMeansAll
}) => {
  const tree = makeTree(options);

  const allOptionKeys = options.map(o => o.key);

  const getActiveOptions = () =>
    noneMeansAll && activeOptions.length === 0 ? allOptionKeys : activeOptions;

  // Whether an item is selected or not
  const isSelected = option => getActiveOptions().indexOf(option.key) > -1;
  const notSelected = option => !isSelected(option);

  // Get array of option objects, given their keys
  const optionsForKeys = keys => options.filter(o => keys.indexOf(o.key) > -1);

  // When an item is deselected, also deselect all ancestors that no longer
  // have any children selected (disregarding the target node that is to be
  // deselected).
  // Also deselect the target node, and all children
  const deselectOption = option =>
    difference(
      optionsForKeys(getActiveOptions()),
      tree
        .ancestors(option)
        .filter(ancestor =>
          tree.allChildren(ancestor, o => o === option || notSelected(o))
        )
        .concat([option])
        .concat(tree.descendants(option))
    );

  // Selecting an item is easier than deselecting. Preserve existing selections
  // and add all the target's nodes ancestors, the target node, and all of its
  // descendants
  const selectOption = option =>
    optionsForKeys(getActiveOptions())
      .concat(tree.ancestors(option))
      .concat([option])
      .concat(tree.descendants(option))
      .filter(o => !!o);

  // o.key is implementation-specific and limits reuse
  const handleToggle = option =>
    isSelected(option)
      ? onChange(uniq(deselectOption(option).map(o => o.key)))
      : onChange(uniq(selectOption(option).map(o => o.key)));

  // Invoke the function children that was given as a prop. Pass it the ALL of
  // the known options, along with boolean active, and a select function
  // that will toggle the option
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

SelectableTree.propTypes = {
  options: PropTypes.arrayOf(optionPropTypes).isRequired, // objects
  activeOptions: PropTypes.arrayOf(PropTypes.string), // active option keys
  onChange: PropTypes.func.isRequired, // receives all active option keys
  children: PropTypes.func.isRequired
};

SelectableTree.defaultProps = {
  activeOptions: []
};

export default SelectableTree;
