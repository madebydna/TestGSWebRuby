import PropTypes from 'prop-types';

// Given a group of siblings, allow one or multiple to be selected by the user
// Selecting one item unselects other items
// When items are selected/unselected, onSelect is called with the active item(s)

const Selectable = ({
  multiple,
  options,
  activeOptions,
  onSelect,
  onDeselect,
  children,
  allowDeselect,
  keyFunc
}) => {
  function isOptionSelected(option) {
    return activeOptions.indexOf(option) > -1;
  }

  function selectOption(option) {
    if (multiple) {
      return activeOptions.concat(option);
    }
    return option;
  }

  function deselectOption(option) {
    if (multiple) {
      return activeOptions.filter(o => o !== option);
    }
    return null;
  }

  function handleSelect(option) {
    let k = option;
    if (keyFunc) {
      k = keyFunc(option);
    }
    if (isOptionSelected(k)) {
      if (allowDeselect !== false) {
        const func = onDeselect || onSelect;
        func(deselectOption(k));
      }
    } else {
      onSelect(selectOption(k));
    }
  }

  return children(
    options.map(option => {
      let k = option;
      if (keyFunc) {
        k = keyFunc(option);
      }

      return {
        option,
        active: isOptionSelected(k),
        select: () => handleSelect(option)
      };
    })
  );
};

Selectable.propTypes = {
  multiple: PropTypes.bool,
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  activeOptions: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.object, PropTypes.string])
  ),
  onSelect: PropTypes.func.isRequired, // called with active keys when option selected
  onDeselect: PropTypes.func, // called with active keys when option is deselected. Defaults to onSelect function
  children: PropTypes.func.isRequired,
  allowDeselect: PropTypes.bool,
  keyFunc: PropTypes.func
};

Selectable.defaultProps = {
  multiple: false,
  activeOptions: [],
  onDeselect: null,
  allowDeselect: true,
  keyFunc: null
};

export default Selectable;
