GS.localStorage = (function(_) {
    var namespace = 'GS.';
    var enabled = !!window.localStorage;

    var setItem = function(key, value, daysToKeep) {
        if (!enabled) {
            return false;
        }

        var expirationDate = new Date();
        if (daysToKeep > 0) {
            expirationDate = expirationDate.setDate(expirationDate.getDate() + daysToKeep);
        } else {
            expirationDate = false;
        }

        value = {value: value, expirationDate: expirationDate};

        try {
            localStorage.setItem(namespace + key, JSON.stringify(value));
        } catch (err) {
            return false;
        }
        return true;
    };

    var getItem = function(key) {
        if (!enabled) {
            return null;
        }
        var value = localStorage.getItem(namespace + key);

        if (value === null) {
            return null;
        }

        if (value[0] === '{' || value[0] === '[') {
            value = JSON.parse(value);
            if (value.expirationDate && new Date(value.expirationDate) < new Date()) {
                removeItem(key);
                return null;
            } else {
                return value.value;
            }
        }

        return value;
    };

    var removeItem = function(key) {
        if (!enabled) {
            return false;
        }
        localStorage.removeItem(namespace + key);
        return true;
    };

    return {
        enabled:enabled,
        setItem:setItem,
        getItem:getItem,
        removeItem:removeItem
    }

})(_);