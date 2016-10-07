'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _react = require('react');

var _react2 = _interopRequireDefault(_react);

var _reactRouter = require('react-router');

var _reactRouterBootstrap = require('react-router-bootstrap');

var _Nav = require('react-bootstrap/lib/Nav');

var _Nav2 = _interopRequireDefault(_Nav);

var _Navbar = require('react-bootstrap/lib/Navbar');

var _Navbar2 = _interopRequireDefault(_Navbar);

var _NavItem = require('react-bootstrap/lib/NavItem');

var _NavItem2 = _interopRequireDefault(_NavItem);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var App = function (_PureComponent) {
  _inherits(App, _PureComponent);

  function App() {
    _classCallCheck(this, App);

    return _possibleConstructorReturn(this, (App.__proto__ || Object.getPrototypeOf(App)).apply(this, arguments));
  }

  _createClass(App, [{
    key: 'render',
    value: function render() {
      var styles = require('./App.scss');

      return _react2.default.createElement(
        'div',
        { className: styles.app },
        _react2.default.createElement(
          _Navbar2.default,
          { fixedTop: true },
          _react2.default.createElement(
            _Navbar2.default.Header,
            null,
            _react2.default.createElement(
              _Navbar2.default.Brand,
              null,
              _react2.default.createElement(
                _reactRouter.IndexLink,
                { to: '/', activeStyle: { color: '#33e0ff' } },
                _react2.default.createElement('div', { className: styles.brand }),
                _react2.default.createElement(
                  'span',
                  null,
                  'Microcrawler'
                )
              )
            ),
            _react2.default.createElement(_Navbar2.default.Toggle, null)
          ),
          _react2.default.createElement(
            _Navbar2.default.Collapse,
            { eventKey: 0 },
            _react2.default.createElement(
              _Nav2.default,
              { navbar: true },
              _react2.default.createElement(
                _reactRouterBootstrap.LinkContainer,
                { to: '/' },
                _react2.default.createElement(
                  _NavItem2.default,
                  { eventKey: 1 },
                  'Home'
                )
              )
            )
          )
        )
      );
    }
  }]);

  return App;
}(_react.PureComponent);

exports.default = App;
//# sourceMappingURL=/js/maps/containers/App.js.map
