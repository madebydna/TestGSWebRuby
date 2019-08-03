module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = require('../../../ssr-module-cache.js');
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		var threw = true;
/******/ 		try {
/******/ 			modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/ 			threw = false;
/******/ 		} finally {
/******/ 			if(threw) delete installedModules[moduleId];
/******/ 		}
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 4);
/******/ })
/************************************************************************/
/******/ ({

/***/ "./components/TestState.jsx":
/*!**********************************!*\
  !*** ./components/TestState.jsx ***!
  \**********************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_classCallCheck__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/classCallCheck */ "./node_modules/@babel/runtime-corejs2/helpers/esm/classCallCheck.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_createClass__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/createClass */ "./node_modules/@babel/runtime-corejs2/helpers/esm/createClass.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_possibleConstructorReturn__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/possibleConstructorReturn */ "./node_modules/@babel/runtime-corejs2/helpers/esm/possibleConstructorReturn.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_getPrototypeOf__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/getPrototypeOf */ "./node_modules/@babel/runtime-corejs2/helpers/esm/getPrototypeOf.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_inherits__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/inherits */ "./node_modules/@babel/runtime-corejs2/helpers/esm/inherits.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_defineProperty__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/defineProperty */ "./node_modules/@babel/runtime-corejs2/helpers/esm/defineProperty.js");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_6___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_6__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! prop-types */ "prop-types");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_7___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_7__);
/* harmony import */ var _TestStateLayout__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./TestStateLayout */ "./components/TestStateLayout.jsx");
/* harmony import */ var _cities_CityBrowseLinks__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! ./cities/CityBrowseLinks */ "./components/cities/CityBrowseLinks.jsx");
/* harmony import */ var _districts_in_state_DistrictsInState__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ./districts_in_state/DistrictsInState */ "./components/districts_in_state/DistrictsInState.jsx");






var _jsxFileName = "/Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/components/TestState.jsx";

 // import Breadcrumbs from 'react_components/breadcrumbs';

 // import DataModule from "react_components/data_module";
// import InfoBox from 'react_components/school_profiles/info_box';
// import SearchBox from 'react_components/search_box'
// import Ad from 'react_components/ad';
// import TopSchoolsStateful from './top_schools_stateful';
// import CsaTopSchools from './csa_top_schools';


 // import RecentReviews from "./recent_reviews";
// import Students from "./students";
// import { init as initAdvertising } from 'util/advertising';
// import { XS, validSizes as validViewportSizes } from 'util/viewport';
// import Toc from './toc';
// import { schoolsTocItem, academicsTocItem, awardWinningSchoolsTocItem, studentsTocItem, schoolDistrictsTocItem, citiesTocItem, reviewsTocItem, AWARD_WINNING_SCHOOLS, STUDENTS, SCHOOL_DISTRICTS, REVIEWS, ACADEMICS } from './toc_config';
// import withViewportSize from 'react_components/with_viewport_size';
// import { find as findSchools } from 'api_clients/schools';
// import { analyticsEvent } from 'util/page_analytics';
// import remove from 'util/array';
// import { t, capitalize } from '../../util/i18n';
// import QualarooDistrictLink from '../qualaroo_district_link';

var TestState =
/*#__PURE__*/
function (_React$Component) {
  Object(_babel_runtime_corejs2_helpers_esm_inherits__WEBPACK_IMPORTED_MODULE_4__["default"])(TestState, _React$Component);

  function TestState(props) {
    var _this;

    Object(_babel_runtime_corejs2_helpers_esm_classCallCheck__WEBPACK_IMPORTED_MODULE_0__["default"])(this, TestState);

    _this = Object(_babel_runtime_corejs2_helpers_esm_possibleConstructorReturn__WEBPACK_IMPORTED_MODULE_2__["default"])(this, Object(_babel_runtime_corejs2_helpers_esm_getPrototypeOf__WEBPACK_IMPORTED_MODULE_3__["default"])(TestState).call(this, props));
    _this.pageType = 'state';
    return _this;
  } // componentDidMount() {
  //   setTimeout(() => {
  //     initAdvertising();
  //   }, 1000);
  // }
  // // school finder methods, based on obj state
  // findTopRatedSchoolsWithReactState(newState = {}) {
  //   return findSchools(
  //     Object.assign(
  //       {
  //         city: this.props.city,
  //         state: this.props.state,
  //         levelCodes: this.props.levelCodes,
  //         extras: ['students_per_teacher', 'review_summary']
  //       },
  //       newState
  //     )
  //   );
  // }
  // hasAcademicsData() {
  //   let { data } = this.props.academics;
  //   return data.filter(o => o.data && o.data.length > 0).length > 0
  // }
  // hasStudentDemographicData() {
  //   const { ethnicityData, genderData, subgroupsData } = this.props.students;
  //   const hasEthnicityData = ethnicityData.filter(o => o.state_value > 0).length > 0
  //   const hasGenderData = genderData.Male !== undefined && genderData.Female !== undefined;
  //   let hasSubgroupsData = false;
  //   Object.entries(subgroupsData).forEach(([key, data]) => {
  //     if (data.length > 0 && data[0].breakdown === 'All students' && data[0].state_value > 0) { hasSubgroupsData = true }
  //   });
  //   return hasEthnicityData || hasGenderData || hasSubgroupsData;
  // }
  // selectTocItems() {
  //   let stateTocItems = [schoolsTocItem, awardWinningSchoolsTocItem, academicsTocItem, studentsTocItem, citiesTocItem, schoolDistrictsTocItem, reviewsTocItem];
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === AWARD_WINNING_SCHOOLS && !this.props.csa_module);
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === SCHOOL_DISTRICTS && this.props.districts.length === 0);
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === REVIEWS && this.props.reviews.length === 0);
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === STUDENTS && !this.hasStudentDemographicData());
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === ACADEMICS && !this.hasAcademicsData());
  //   return stateTocItems;
  // }


  Object(_babel_runtime_corejs2_helpers_esm_createClass__WEBPACK_IMPORTED_MODULE_1__["default"])(TestState, [{
    key: "render",
    value: function render() {
      // let { title, anchor, subtitle, info_text, icon_classes, sources, share_content, rating, data, analytics_id, showTabs, faq, feedback } = this.props.academics;
      // const studentProps = { ...this.props.students, ...{ 'pageType': this.pageType } }
      return react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement(_TestStateLayout__WEBPACK_IMPORTED_MODULE_8__["default"], {
        locality: {
          nameLong: 'Andyville'
        },
        schoolCount: 40,
        districts: this.props.districts,
        shouldDisplayDistricts: true,
        districtsInState: react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement(_districts_in_state_DistrictsInState__WEBPACK_IMPORTED_MODULE_10__["default"], {
          districts: this.props.districts,
          locality: this.props.locality,
          __source: {
            fileName: _jsxFileName,
            lineNumber: 120
          },
          __self: this
        }),
        browseCities: react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement(_cities_CityBrowseLinks__WEBPACK_IMPORTED_MODULE_9__["default"], {
          community: this.pageType,
          locality: this.props.locality // size={this.props.viewportSize}
          ,
          cities: this.props.cities,
          __source: {
            fileName: _jsxFileName,
            lineNumber: 126
          },
          __self: this
        }) // breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
        // viewportSize={this.props.viewportSize}
        ,
        __source: {
          fileName: _jsxFileName,
          lineNumber: 112
        },
        __self: this
      });
    } // render(){
    //   <DistrictsInState
    //     districts={this.props.districts}
    //     locality={this.props.locality}
    //   />
    // }

  }]);

  return TestState;
}(react__WEBPACK_IMPORTED_MODULE_6___default.a.Component); // const StateWithViewportSize = withViewportSize('size')(TestState);


Object(_babel_runtime_corejs2_helpers_esm_defineProperty__WEBPACK_IMPORTED_MODULE_5__["default"])(TestState, "defaultProps", {
  schools_data: {},
  loadingSchools: false,
  breadcrumbs: [],
  districts: [],
  reviews: [],
  cities: [],
  csa_module: false
});

Object(_babel_runtime_corejs2_helpers_esm_defineProperty__WEBPACK_IMPORTED_MODULE_5__["default"])(TestState, "propTypes", {
  schools_data: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.object,
  districts: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.arrayOf(prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.object),
  reviews: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.arrayOf(prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.object),
  // viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
  breadcrumbs: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.arrayOf(prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.shape({
    text: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.string.isRequired,
    url: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.string.isRequired
  })),
  locality: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.object.isRequired,
  cities: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.array,
  schoolCount: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.number,
  csa_module: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.bool,
  students: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.object
});

/* harmony default export */ __webpack_exports__["default"] = (TestState);

/***/ }),

/***/ "./components/TestStateLayout.jsx":
/*!****************************************!*\
  !*** ./components/TestStateLayout.jsx ***!
  \****************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_classCallCheck__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/classCallCheck */ "./node_modules/@babel/runtime-corejs2/helpers/esm/classCallCheck.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_createClass__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/createClass */ "./node_modules/@babel/runtime-corejs2/helpers/esm/createClass.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_possibleConstructorReturn__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/possibleConstructorReturn */ "./node_modules/@babel/runtime-corejs2/helpers/esm/possibleConstructorReturn.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_getPrototypeOf__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/getPrototypeOf */ "./node_modules/@babel/runtime-corejs2/helpers/esm/getPrototypeOf.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_inherits__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/inherits */ "./node_modules/@babel/runtime-corejs2/helpers/esm/inherits.js");
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_defineProperty__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/defineProperty */ "./node_modules/@babel/runtime-corejs2/helpers/esm/defineProperty.js");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_6___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_6__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! prop-types */ "prop-types");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_7___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_7__);






var _jsxFileName = "/Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/components/TestStateLayout.jsx";

 // import { XS, SM, LG, MD, validSizes } from 'util/viewport';
// import OpenableCloseable from 'react_components/openable_closeable';
// import Button from 'react_components/button';
// import Ad from 'react_components/ad';
// import { t, capitalize } from 'util/i18n';
// import { keepInViewport } from 'util/sticky';

var TestStateLayout =
/*#__PURE__*/
function (_React$Component) {
  Object(_babel_runtime_corejs2_helpers_esm_inherits__WEBPACK_IMPORTED_MODULE_4__["default"])(TestStateLayout, _React$Component);

  function TestStateLayout(props) {
    Object(_babel_runtime_corejs2_helpers_esm_classCallCheck__WEBPACK_IMPORTED_MODULE_0__["default"])(this, TestStateLayout);

    return Object(_babel_runtime_corejs2_helpers_esm_possibleConstructorReturn__WEBPACK_IMPORTED_MODULE_2__["default"])(this, Object(_babel_runtime_corejs2_helpers_esm_getPrototypeOf__WEBPACK_IMPORTED_MODULE_3__["default"])(TestStateLayout).call(this, props)); // this.ad = React.createRef();
    // this.breadcrumbs = React.createRef();
    // this.toc = React.createRef();
    // this.state = {}
  }

  Object(_babel_runtime_corejs2_helpers_esm_createClass__WEBPACK_IMPORTED_MODULE_1__["default"])(TestStateLayout, [{
    key: "componentDidMount",
    value: function componentDidMount() {// keepInViewport(this.breadcrumbs, {
      //   initialTop: 60,
      //   setTop: true,
      //   setBottom: false
      // });
      // keepInViewport(this.ad, {
      //   $elementsAbove: [$('.header_un')],
      //   $elementsBelow: [$('.footer')],
      //   setTop: true,
      //   setBottom: true
      // });
      // keepInViewport(this.toc, {
      //   $elementsAbove: [$('.header_un')],
      //   $elementsBelow: [$('.footer')],
      //   setTop: true,
      //   setBottom: true
      // });
    }
  }, {
    key: "heroTitle",
    value: function heroTitle() {
      var nameLong = this.props.locality.nameLong; // return t('state.state_hero_title', { parameters: { nameLong } });

      return "".concat(nameLong);
    }
  }, {
    key: "heroNarration",
    value: function heroNarration() {
      var nameLong = this.props.locality.nameLong;
      var schoolCount = this.props.schoolCount.toLocaleString();
      return "AMERICA'S HERO";
    }
  }, {
    key: "renderHero",
    value: function renderHero() {
      return react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        id: "hero",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 61
        },
        __self: this
      }, react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        __source: {
          fileName: _jsxFileName,
          lineNumber: 62
        },
        __self: this
      }, react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("h1", {
        className: "state-hero-title",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 63
        },
        __self: this
      }, this.heroTitle()), react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        className: "state-hero-narrative",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 64
        },
        __self: this
      }, this.heroNarration())));
    }
  }, {
    key: "renderBreadcrumbs",
    value: function renderBreadcrumbs() {
      return react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        className: "breadcrumbs-container",
        ref: this.breadcrumbs,
        __source: {
          fileName: _jsxFileName,
          lineNumber: 70
        },
        __self: this
      }, this.props.breadcrumbs);
    }
  }, {
    key: "renderBoxAd",
    value: function renderBoxAd() {
      return react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        id: "second-ad",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 74
        },
        __self: this
      }, react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement(Ad, {
        slot: "statepage_second",
        sizeName: "box",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 75
        },
        __self: this
      }));
    }
  }, {
    key: "renderDesktopAd",
    value: function renderDesktopAd() {} // return this.props.viewportSize > SM && <div className="ad-bar sticky" >
    //   <Ad slot="statepage_first" sizeName="box_or_tall" />
    // </div>
    // renderToc() {
    //   return this.props.viewportSize > XS && <div ref={this.toc} className="toc sticky">{this.props.toc}</div>
    // }

  }, {
    key: "renderDistricts",
    value: function renderDistricts() {
      var nameLong = this.props.locality.nameLong;
      return this.props.shouldDisplayDistricts && react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        id: "districts",
        className: "module-section",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 93
        },
        __self: this
      }, react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        className: "modules-title",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 94
        },
        __self: this
      }, 'Largest school districts in California'), this.props.districtsInState);
    } // renderAcademics() {
    //   return (
    //     <div id="academics" className="module-section">
    //       {this.props.academics}
    //     </div>
    //   )
    // }
    // renderSchools() {
    //   let { nameLong } = this.props.locality;
    //   const browseHeader = "Header";
    //   return (
    //     <div id="schools" className="module-section">
    //       <div className="modules-title">{browseHeader}</div>
    //       {this.props.topSchools}
    //     </div>
    //   )
    // }

  }, {
    key: "renderCities",
    value: function renderCities() {
      return react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        id: "cities",
        className: "module-section",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 122
        },
        __self: this
      }, this.props.browseCities);
    } // renderStudentsModule() {
    //   return (this.props.hasStudentDemographicData &&
    //     <div id="students" className="module-section">
    //       {this.props.students}
    //     </div>
    //   )
    // }
    // renderCsaModule() {
    //   return this.props.shouldDisplayCsaInfo && (
    //     <div id="award-winning-schools" className="module-section">
    //       {this.props.csaTopSchools}
    //     </div>
    //   );
    // }
    // renderReviews() {
    //   return (
    //     this.props.shouldDisplayReviews &&
    //     <div id="reviews" className="module-section">
    //       <div className="rating-container reviews-module">
    //         <h3>{t('recent_reviews.title')} {`${this.props.locality.nameLong}`}</h3>
    //         {this.props.recentReviews}
    //       </div>
    //     </div>
    //   )
    // }

  }, {
    key: "render",
    value: function render() {
      return react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        className: "state-body",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 158
        },
        __self: this
      }, react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        className: "below-hero",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 162
        },
        __self: this
      }, react__WEBPACK_IMPORTED_MODULE_6___default.a.createElement("div", {
        className: "community-modules",
        __source: {
          fileName: _jsxFileName,
          lineNumber: 165
        },
        __self: this
      }, this.renderCities(), this.renderDistricts())));
    }
  }]);

  return TestStateLayout;
}(react__WEBPACK_IMPORTED_MODULE_6___default.a.Component);

Object(_babel_runtime_corejs2_helpers_esm_defineProperty__WEBPACK_IMPORTED_MODULE_5__["default"])(TestStateLayout, "propTypes", {
  // viewportSize: PropTypes.oneOf(validSizes).isRequired,
  // searchBox: PropTypes.element.isRequired,
  // breadcrumbs: PropTypes.element,
  shouldDisplayDistricts: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.bool,
  shouldDisplayReviews: prop_types__WEBPACK_IMPORTED_MODULE_7___default.a.bool
});

/* harmony default export */ __webpack_exports__["default"] = (TestStateLayout);

/***/ }),

/***/ "./components/cities/CityBrowseLinks.jsx":
/*!***********************************************!*\
  !*** ./components/cities/CityBrowseLinks.jsx ***!
  \***********************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! prop-types */ "prop-types");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _CityLinks__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./CityLinks */ "./components/cities/CityLinks.jsx");
var _jsxFileName = "/Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/components/cities/CityBrowseLinks.jsx";

 // import { validSizes as validViewportSizes } from "util/viewport";

 // import { t } from "util/i18n";

var cityBrowseLinks = function cityBrowseLinks(_ref) {
  var locality = _ref.locality,
      size = _ref.size,
      cities = _ref.cities;
  var browseSchoolBlurb = react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("h3", {
    __source: {
      fileName: _jsxFileName,
      lineNumber: 9
    },
    __self: this
  }, "Cities");
  console.log(cities);
  return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("section", {
    className: "links-module",
    __source: {
      fileName: _jsxFileName,
      lineNumber: 12
    },
    __self: this
  }, browseSchoolBlurb, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("ul", {
    __source: {
      fileName: _jsxFileName,
      lineNumber: 14
    },
    __self: this
  }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_CityLinks__WEBPACK_IMPORTED_MODULE_2__["default"], {
    cities: cities,
    size: size,
    __source: {
      fileName: _jsxFileName,
      lineNumber: 15
    },
    __self: this
  })), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
    className: "separator",
    __source: {
      fileName: _jsxFileName,
      lineNumber: 17
    },
    __self: this
  }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
    className: "blue-line",
    __source: {
      fileName: _jsxFileName,
      lineNumber: 18
    },
    __self: this
  })), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
    className: "more-school-btn",
    __source: {
      fileName: _jsxFileName,
      lineNumber: 20
    },
    __self: this
  }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("a", {
    href: locality.citiesBrowseUrl,
    __source: {
      fileName: _jsxFileName,
      lineNumber: 21
    },
    __self: this
  }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("button", {
    __source: {
      fileName: _jsxFileName,
      lineNumber: 22
    },
    __self: this
  }, "Browse More"))));
};

cityBrowseLinks.propTypes = {
  locality: prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.object.isRequired,
  // size: PropTypes.oneOf(validViewportSizes).isRequired,
  community: prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.string.isRequired,
  cities: prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.array
};
cityBrowseLinks.defaultProps = {
  cities: []
};
/* harmony default export */ __webpack_exports__["default"] = (cityBrowseLinks);

/***/ }),

/***/ "./components/cities/CityLinks.jsx":
/*!*****************************************!*\
  !*** ./components/cities/CityLinks.jsx ***!
  \*****************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! prop-types */ "prop-types");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_1__);
var _jsxFileName = "/Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/components/cities/CityLinks.jsx";

 // import { MD, validSizes as validViewportSizes } from "util/viewport";

var renderCitiesListItem = function renderCitiesListItem(linkData) {
  return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("a", {
    href: linkData.url,
    __source: {
      fileName: _jsxFileName,
      lineNumber: 6
    },
    __self: this
  }, linkData.name);
};

var cityLinks = function cityLinks(_ref) {
  var size = _ref.size,
      cities = _ref.cities;
  var renderedList = cities.map(function (linkData, idx) {
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("li", {
      key: linkData.name,
      __source: {
        fileName: _jsxFileName,
        lineNumber: 11
      },
      __self: this
    }, renderCitiesListItem(linkData), renderBlueLine(idx, cities.length, size));
  });
  return renderedList;
}; // large screens display cities in two cols with 4 cities each


var renderBlueLine = function renderBlueLine(idx, num_cities, size) {
  var notLast = idx !== num_cities - 1; // const twoCol = size > MD;

  var twoCol = true;
  var lastInFirstCol = idx == 3;

  if (notLast && !(twoCol && lastInFirstCol)) {
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
      className: "blue-line",
      __source: {
        fileName: _jsxFileName,
        lineNumber: 26
      },
      __self: this
    });
  }
};

cityLinks.propTypes = {
  cities: prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.array // size: PropTypes.oneOf(validViewportSizes).isRequired

};
/* harmony default export */ __webpack_exports__["default"] = (cityLinks);

/***/ }),

/***/ "./components/districts_in_state/DistrictsInState.jsx":
/*!************************************************************!*\
  !*** ./components/districts_in_state/DistrictsInState.jsx ***!
  \************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! prop-types */ "prop-types");
/* harmony import */ var prop_types__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(prop_types__WEBPACK_IMPORTED_MODULE_1__);
var _jsxFileName = "/Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/components/districts_in_state/DistrictsInState.jsx";

 // import { t } from "util/i18n";
// import { copyParam } from 'util/uri';

var districtLink = function districtLink(link) {
  return link;
};

var DistrictsInState = function DistrictsInState(_ref) {
  var districts = _ref.districts,
      _ref$locality = _ref.locality,
      locality = _ref$locality === void 0 ? {} : _ref$locality;
  console.log(districts);
  var districtItems = districts.map(function (district, idx) {
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("li", {
      key: district.name,
      __source: {
        fileName: _jsxFileName,
        lineNumber: 13
      },
      __self: this
    }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("a", {
      href: districtLink(district.url),
      __source: {
        fileName: _jsxFileName,
        lineNumber: 14
      },
      __self: this
    }, district.name), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
      __source: {
        fileName: _jsxFileName,
        lineNumber: 15
      },
      __self: this
    }, district.enrollment ? react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", {
      __source: {
        fileName: _jsxFileName,
        lineNumber: 16
      },
      __self: this
    }, district.enrollment.toLocaleString(), " ", 'Students', react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", {
      className: "display-desktop",
      __source: {
        fileName: _jsxFileName,
        lineNumber: 16
      },
      __self: this
    }, " | ")) : null, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", {
      __source: {
        fileName: _jsxFileName,
        lineNumber: 17
      },
      __self: this
    }, district.city, ", ", district.state), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("br", {
      __source: {
        fileName: _jsxFileName,
        lineNumber: 18
      },
      __self: this
    }), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", {
      __source: {
        fileName: _jsxFileName,
        lineNumber: 19
      },
      __self: this
    }, "Grades", ": ", district.grades, " | "), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", {
      __source: {
        fileName: _jsxFileName,
        lineNumber: 20
      },
      __self: this
    }, district.numSchools.toLocaleString(), " ", district.numSchools === 1 ? 'school' : 'schools')), idx !== districts.length - 1 ? react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
      className: "blue-line",
      __source: {
        fileName: _jsxFileName,
        lineNumber: 22
      },
      __self: this
    }) : null);
  });
  return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("section", {
    className: "districts-in-state-module",
    __source: {
      fileName: _jsxFileName,
      lineNumber: 26
    },
    __self: this
  }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("ul", {
    __source: {
      fileName: _jsxFileName,
      lineNumber: 27
    },
    __self: this
  }, districtItems), react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", {
    className: "blue-line",
    __source: {
      fileName: _jsxFileName,
      lineNumber: 31
    },
    __self: this
  }));
};

DistrictsInState.propTypes = {
  districts: prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.arrayOf(prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.object).isRequired,
  locality: prop_types__WEBPACK_IMPORTED_MODULE_1___default.a.object.isRequired
};
DistrictsInState.defaultProps = {
  districts: []
};
/* harmony default export */ __webpack_exports__["default"] = (DistrictsInState);

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/object/create.js":
/*!**********************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/object/create.js ***!
  \**********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/object/create */ "core-js/library/fn/object/create");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/object/define-property.js":
/*!*******************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/object/define-property.js ***!
  \*******************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/object/define-property */ "core-js/library/fn/object/define-property");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/object/get-prototype-of.js":
/*!********************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/object/get-prototype-of.js ***!
  \********************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/object/get-prototype-of */ "core-js/library/fn/object/get-prototype-of");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/object/set-prototype-of.js":
/*!********************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/object/set-prototype-of.js ***!
  \********************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/object/set-prototype-of */ "core-js/library/fn/object/set-prototype-of");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/promise.js":
/*!****************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/promise.js ***!
  \****************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/promise */ "core-js/library/fn/promise");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/symbol.js":
/*!***************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/symbol.js ***!
  \***************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/symbol */ "core-js/library/fn/symbol");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/core-js/symbol/iterator.js":
/*!************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/core-js/symbol/iterator.js ***!
  \************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! core-js/library/fn/symbol/iterator */ "core-js/library/fn/symbol/iterator");

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/assertThisInitialized.js":
/*!**********************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/assertThisInitialized.js ***!
  \**********************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _assertThisInitialized; });
function _assertThisInitialized(self) {
  if (self === void 0) {
    throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
  }

  return self;
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/asyncToGenerator.js":
/*!*****************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/asyncToGenerator.js ***!
  \*****************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _asyncToGenerator; });
/* harmony import */ var _core_js_promise__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/promise */ "./node_modules/@babel/runtime-corejs2/core-js/promise.js");
/* harmony import */ var _core_js_promise__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_promise__WEBPACK_IMPORTED_MODULE_0__);


function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) {
  try {
    var info = gen[key](arg);
    var value = info.value;
  } catch (error) {
    reject(error);
    return;
  }

  if (info.done) {
    resolve(value);
  } else {
    _core_js_promise__WEBPACK_IMPORTED_MODULE_0___default.a.resolve(value).then(_next, _throw);
  }
}

function _asyncToGenerator(fn) {
  return function () {
    var self = this,
        args = arguments;
    return new _core_js_promise__WEBPACK_IMPORTED_MODULE_0___default.a(function (resolve, reject) {
      var gen = fn.apply(self, args);

      function _next(value) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value);
      }

      function _throw(err) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err);
      }

      _next(undefined);
    });
  };
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/classCallCheck.js":
/*!***************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/classCallCheck.js ***!
  \***************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _classCallCheck; });
function _classCallCheck(instance, Constructor) {
  if (!(instance instanceof Constructor)) {
    throw new TypeError("Cannot call a class as a function");
  }
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/createClass.js":
/*!************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/createClass.js ***!
  \************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _createClass; });
/* harmony import */ var _core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/object/define-property */ "./node_modules/@babel/runtime-corejs2/core-js/object/define-property.js");
/* harmony import */ var _core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0__);


function _defineProperties(target, props) {
  for (var i = 0; i < props.length; i++) {
    var descriptor = props[i];
    descriptor.enumerable = descriptor.enumerable || false;
    descriptor.configurable = true;
    if ("value" in descriptor) descriptor.writable = true;

    _core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0___default()(target, descriptor.key, descriptor);
  }
}

function _createClass(Constructor, protoProps, staticProps) {
  if (protoProps) _defineProperties(Constructor.prototype, protoProps);
  if (staticProps) _defineProperties(Constructor, staticProps);
  return Constructor;
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/defineProperty.js":
/*!***************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/defineProperty.js ***!
  \***************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _defineProperty; });
/* harmony import */ var _core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/object/define-property */ "./node_modules/@babel/runtime-corejs2/core-js/object/define-property.js");
/* harmony import */ var _core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0__);

function _defineProperty(obj, key, value) {
  if (key in obj) {
    _core_js_object_define_property__WEBPACK_IMPORTED_MODULE_0___default()(obj, key, {
      value: value,
      enumerable: true,
      configurable: true,
      writable: true
    });
  } else {
    obj[key] = value;
  }

  return obj;
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/getPrototypeOf.js":
/*!***************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/getPrototypeOf.js ***!
  \***************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _getPrototypeOf; });
/* harmony import */ var _core_js_object_get_prototype_of__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/object/get-prototype-of */ "./node_modules/@babel/runtime-corejs2/core-js/object/get-prototype-of.js");
/* harmony import */ var _core_js_object_get_prototype_of__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_object_get_prototype_of__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../core-js/object/set-prototype-of */ "./node_modules/@babel/runtime-corejs2/core-js/object/set-prototype-of.js");
/* harmony import */ var _core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_1__);


function _getPrototypeOf(o) {
  _getPrototypeOf = _core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_1___default.a ? _core_js_object_get_prototype_of__WEBPACK_IMPORTED_MODULE_0___default.a : function _getPrototypeOf(o) {
    return o.__proto__ || _core_js_object_get_prototype_of__WEBPACK_IMPORTED_MODULE_0___default()(o);
  };
  return _getPrototypeOf(o);
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/inherits.js":
/*!*********************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/inherits.js ***!
  \*********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _inherits; });
/* harmony import */ var _core_js_object_create__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/object/create */ "./node_modules/@babel/runtime-corejs2/core-js/object/create.js");
/* harmony import */ var _core_js_object_create__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_object_create__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _setPrototypeOf__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./setPrototypeOf */ "./node_modules/@babel/runtime-corejs2/helpers/esm/setPrototypeOf.js");


function _inherits(subClass, superClass) {
  if (typeof superClass !== "function" && superClass !== null) {
    throw new TypeError("Super expression must either be null or a function");
  }

  subClass.prototype = _core_js_object_create__WEBPACK_IMPORTED_MODULE_0___default()(superClass && superClass.prototype, {
    constructor: {
      value: subClass,
      writable: true,
      configurable: true
    }
  });
  if (superClass) Object(_setPrototypeOf__WEBPACK_IMPORTED_MODULE_1__["default"])(subClass, superClass);
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/possibleConstructorReturn.js":
/*!**************************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/possibleConstructorReturn.js ***!
  \**************************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _possibleConstructorReturn; });
/* harmony import */ var _helpers_esm_typeof__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../helpers/esm/typeof */ "./node_modules/@babel/runtime-corejs2/helpers/esm/typeof.js");
/* harmony import */ var _assertThisInitialized__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./assertThisInitialized */ "./node_modules/@babel/runtime-corejs2/helpers/esm/assertThisInitialized.js");


function _possibleConstructorReturn(self, call) {
  if (call && (Object(_helpers_esm_typeof__WEBPACK_IMPORTED_MODULE_0__["default"])(call) === "object" || typeof call === "function")) {
    return call;
  }

  return Object(_assertThisInitialized__WEBPACK_IMPORTED_MODULE_1__["default"])(self);
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/setPrototypeOf.js":
/*!***************************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/setPrototypeOf.js ***!
  \***************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _setPrototypeOf; });
/* harmony import */ var _core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/object/set-prototype-of */ "./node_modules/@babel/runtime-corejs2/core-js/object/set-prototype-of.js");
/* harmony import */ var _core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_0__);

function _setPrototypeOf(o, p) {
  _setPrototypeOf = _core_js_object_set_prototype_of__WEBPACK_IMPORTED_MODULE_0___default.a || function _setPrototypeOf(o, p) {
    o.__proto__ = p;
    return o;
  };

  return _setPrototypeOf(o, p);
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/helpers/esm/typeof.js":
/*!*******************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/helpers/esm/typeof.js ***!
  \*******************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return _typeof; });
/* harmony import */ var _core_js_symbol_iterator__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../core-js/symbol/iterator */ "./node_modules/@babel/runtime-corejs2/core-js/symbol/iterator.js");
/* harmony import */ var _core_js_symbol_iterator__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_core_js_symbol_iterator__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _core_js_symbol__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../core-js/symbol */ "./node_modules/@babel/runtime-corejs2/core-js/symbol.js");
/* harmony import */ var _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_core_js_symbol__WEBPACK_IMPORTED_MODULE_1__);



function _typeof2(obj) { if (typeof _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a === "function" && typeof _core_js_symbol_iterator__WEBPACK_IMPORTED_MODULE_0___default.a === "symbol") { _typeof2 = function _typeof2(obj) { return typeof obj; }; } else { _typeof2 = function _typeof2(obj) { return obj && typeof _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a === "function" && obj.constructor === _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a && obj !== _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a.prototype ? "symbol" : typeof obj; }; } return _typeof2(obj); }

function _typeof(obj) {
  if (typeof _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a === "function" && _typeof2(_core_js_symbol_iterator__WEBPACK_IMPORTED_MODULE_0___default.a) === "symbol") {
    _typeof = function _typeof(obj) {
      return _typeof2(obj);
    };
  } else {
    _typeof = function _typeof(obj) {
      return obj && typeof _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a === "function" && obj.constructor === _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a && obj !== _core_js_symbol__WEBPACK_IMPORTED_MODULE_1___default.a.prototype ? "symbol" : _typeof2(obj);
    };
  }

  return _typeof(obj);
}

/***/ }),

/***/ "./node_modules/@babel/runtime-corejs2/regenerator/index.js":
/*!******************************************************************!*\
  !*** ./node_modules/@babel/runtime-corejs2/regenerator/index.js ***!
  \******************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! regenerator-runtime */ "regenerator-runtime");


/***/ }),

/***/ "./pages/index.jsx":
/*!*************************!*\
  !*** ./pages/index.jsx ***!
  \*************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _babel_runtime_corejs2_regenerator__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @babel/runtime-corejs2/regenerator */ "./node_modules/@babel/runtime-corejs2/regenerator/index.js");
/* harmony import */ var _babel_runtime_corejs2_regenerator__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_babel_runtime_corejs2_regenerator__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _babel_runtime_corejs2_helpers_esm_asyncToGenerator__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @babel/runtime-corejs2/helpers/esm/asyncToGenerator */ "./node_modules/@babel/runtime-corejs2/helpers/esm/asyncToGenerator.js");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! react */ "react");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _components_TestState__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../components/TestState */ "./components/TestState.jsx");
/* harmony import */ var isomorphic_unfetch__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! isomorphic-unfetch */ "isomorphic-unfetch");
/* harmony import */ var isomorphic_unfetch__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(isomorphic_unfetch__WEBPACK_IMPORTED_MODULE_4__);
/* harmony import */ var _stylesheets_communities_next_scss__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ../stylesheets/communities-next.scss */ "./stylesheets/communities-next.scss");
/* harmony import */ var _stylesheets_communities_next_scss__WEBPACK_IMPORTED_MODULE_5___default = /*#__PURE__*/__webpack_require__.n(_stylesheets_communities_next_scss__WEBPACK_IMPORTED_MODULE_5__);


var _jsxFileName = "/Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/pages/index.jsx";


 // import yamlEn from '../yaml/javascript.en.yml'
// import yamlEs from '../yaml/javascript.es.yml'
// import '../stylesheets/styles.scss'
// import '../stylesheets/styles2.scss'

 // import '../../../../../../app/assets/stylesheets/community_post_load2.css.scss'

var Index = function Index(props) {
  var districts = props.data.districts;
  var cities = props.data.cities; // console.log(yamlEn)

  return react__WEBPACK_IMPORTED_MODULE_2___default.a.createElement("div", {
    __source: {
      fileName: _jsxFileName,
      lineNumber: 15
    },
    __self: this
  }, react__WEBPACK_IMPORTED_MODULE_2___default.a.createElement("p", {
    __source: {
      fileName: _jsxFileName,
      lineNumber: 16
    },
    __self: this
  }, "Hello Next.js 2"), react__WEBPACK_IMPORTED_MODULE_2___default.a.createElement(_components_TestState__WEBPACK_IMPORTED_MODULE_3__["default"], {
    districts: districts,
    locality: {
      nameLong: 'Andyville'
    },
    cities: cities,
    __source: {
      fileName: _jsxFileName,
      lineNumber: 17
    },
    __self: this
  }));
};

Index.getInitialProps =
/*#__PURE__*/
function () {
  var _ref = Object(_babel_runtime_corejs2_helpers_esm_asyncToGenerator__WEBPACK_IMPORTED_MODULE_1__["default"])(
  /*#__PURE__*/
  _babel_runtime_corejs2_regenerator__WEBPACK_IMPORTED_MODULE_0___default.a.mark(function _callee(stuff) {
    var res, data;
    return _babel_runtime_corejs2_regenerator__WEBPACK_IMPORTED_MODULE_0___default.a.wrap(function _callee$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            _context.next = 2;
            return isomorphic_unfetch__WEBPACK_IMPORTED_MODULE_4___default()('http://localhost:3000/new-york/state_page_props');

          case 2:
            res = _context.sent;
            _context.next = 5;
            return res.json();

          case 5:
            data = _context.sent;
            console.log(data);
            return _context.abrupt("return", {
              data: data
            });

          case 8:
          case "end":
            return _context.stop();
        }
      }
    }, _callee);
  }));

  return function (_x) {
    return _ref.apply(this, arguments);
  };
}();

/* harmony default export */ __webpack_exports__["default"] = (Index);

/***/ }),

/***/ "./stylesheets/communities-next.scss":
/*!*******************************************!*\
  !*** ./stylesheets/communities-next.scss ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports) {



/***/ }),

/***/ 4:
/*!*******************************!*\
  !*** multi ./pages/index.jsx ***!
  \*******************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! /Users/aluo/Development/GSWebRuby/client/app/bundles/GSWeb/next/pages/index.jsx */"./pages/index.jsx");


/***/ }),

/***/ "core-js/library/fn/object/create":
/*!***************************************************!*\
  !*** external "core-js/library/fn/object/create" ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/object/create");

/***/ }),

/***/ "core-js/library/fn/object/define-property":
/*!************************************************************!*\
  !*** external "core-js/library/fn/object/define-property" ***!
  \************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/object/define-property");

/***/ }),

/***/ "core-js/library/fn/object/get-prototype-of":
/*!*************************************************************!*\
  !*** external "core-js/library/fn/object/get-prototype-of" ***!
  \*************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/object/get-prototype-of");

/***/ }),

/***/ "core-js/library/fn/object/set-prototype-of":
/*!*************************************************************!*\
  !*** external "core-js/library/fn/object/set-prototype-of" ***!
  \*************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/object/set-prototype-of");

/***/ }),

/***/ "core-js/library/fn/promise":
/*!*********************************************!*\
  !*** external "core-js/library/fn/promise" ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/promise");

/***/ }),

/***/ "core-js/library/fn/symbol":
/*!********************************************!*\
  !*** external "core-js/library/fn/symbol" ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/symbol");

/***/ }),

/***/ "core-js/library/fn/symbol/iterator":
/*!*****************************************************!*\
  !*** external "core-js/library/fn/symbol/iterator" ***!
  \*****************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("core-js/library/fn/symbol/iterator");

/***/ }),

/***/ "isomorphic-unfetch":
/*!*************************************!*\
  !*** external "isomorphic-unfetch" ***!
  \*************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("isomorphic-unfetch");

/***/ }),

/***/ "prop-types":
/*!*****************************!*\
  !*** external "prop-types" ***!
  \*****************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("prop-types");

/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "react" ***!
  \************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("react");

/***/ }),

/***/ "regenerator-runtime":
/*!**************************************!*\
  !*** external "regenerator-runtime" ***!
  \**************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = require("regenerator-runtime");

/***/ })

/******/ });
//# sourceMappingURL=index.js.map