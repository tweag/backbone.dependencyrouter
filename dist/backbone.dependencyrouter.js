(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Backbone.Marionette.DependencyRouter = (function(_super) {
    __extends(DependencyRouter, _super);

    function DependencyRouter() {
      var _this = this;
      if (!_.isFunction(this.before)) {
        throw "Backbone RouteFilter required";
      }
      if (_.isUndefined(this.vent)) {
        throw "Must assign .vent to an instance of Backbone.Wreqr";
      }
      DependencyRouter.__super__.constructor.apply(this, arguments);
      this.cid = _.uniqueId();
      this._initResolvedActions();
      this.on("route", function(action, params) {
        _this.clearDependenciesNotFor(action);
        return _this.runDependencyFor(action, params);
      });
      this.vent.on("router:action", function(cid) {
        if (cid !== _this.cid) {
          return _this._initResolvedActions();
        }
      });
    }

    DependencyRouter.prototype.after = function() {
      return this.vent.trigger("router:action", this.cid);
    };

    DependencyRouter.prototype.route = function(route, name, callback) {
      var wrappedCallback,
        _this = this;
      wrappedCallback = function() {
        if (_this._isResolved(name, arguments)) {
          return;
        }
        return callback.apply(_this, arguments);
      };
      return DependencyRouter.__super__.route.call(this, route, name, wrappedCallback);
    };

    DependencyRouter.prototype.runDependencyFor = function(action, params) {
      var _this = this;
      this._resolve(action, params);
      return _.each(this._getDependencyArray(action), function(depMethod) {
        var _ref;
        if (!_this._isResolved(depMethod, params)) {
          _this._resolve(depMethod, params);
          return (_ref = _this._getController())[depMethod].apply(_ref, params);
        }
      });
    };

    DependencyRouter.prototype.clearDependenciesNotFor = function(action) {
      var _this = this;
      return _.each(_.keys(this.resolvedActions), function(key) {
        if (!_.contains(_this._getDependencyArray(action), key)) {
          return delete _this.resolvedActions[key];
        }
      });
    };

    DependencyRouter.prototype._initResolvedActions = function() {
      return this.resolvedActions = {};
    };

    DependencyRouter.prototype._resolve = function(action, params) {
      params = this._paramsFor(action, _.toArray(params));
      return this.resolvedActions[action] = params;
    };

    DependencyRouter.prototype._isResolved = function(action, params) {
      params = this._paramsFor(action, _.toArray(params));
      return _.isEqual(this.resolvedActions[action], params);
    };

    DependencyRouter.prototype._paramsFor = function(action, params) {
      var numberOfParams, regex, route, _ref;
      this.reverseRoutes || (this.reverseRoutes = _.invert(this.appRoutes));
      regex = /:[^/]+/g;
      route = this.reverseRoutes[action];
      numberOfParams = ((_ref = route.match(regex)) != null ? _ref.length : void 0) || 0;
      return params.slice(0, numberOfParams);
    };

    DependencyRouter.prototype._getDependencyArray = function(action) {
      var dependencies, _ref;
      dependencies = (_ref = this.dependencies) != null ? _ref[action] : void 0;
      if (typeof dependencies === "string") {
        dependencies = [dependencies];
      }
      return dependencies || [];
    };

    return DependencyRouter;

  })(Backbone.Marionette.AppRouter);

}).call(this);
