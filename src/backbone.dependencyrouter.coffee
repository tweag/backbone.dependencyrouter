class Backbone.Marionette.DependencyRouter extends Backbone.Marionette.AppRouter
  constructor: ->
    throw "Backbone RouteFilter required" unless _.isFunction(@before)
    super
    @cid = _.uniqueId()
    @_initResolvedActions()
    @on "route", (action, params) =>
      @clearDependenciesNotFor(action)
      @runDependencyFor(action, params)

    @vent.on "router:action", (cid) =>
      @_initResolvedActions() if cid isnt this.cid

  after: -> @vent.trigger("router:action", @cid)

  route: (route, name, callback) ->
    wrappedCallback = =>
      return if @_isResolved(name, arguments)
      callback.apply(this, arguments)

    super(route, name, wrappedCallback)

  runDependencyFor: (action, params) ->
    @_resolve(action, params)
    _.each @_getDependencyArray(action), (depMethod) =>
      unless @_isResolved(depMethod, params)
        @_resolve(depMethod, params)
        @_getController()[depMethod](params...)

  clearDependenciesNotFor: (action) ->
    _.each _.keys(@resolvedActions), (key) =>
      unless _.contains(@_getDependencyArray(action), key)
        delete @resolvedActions[key]

  _initResolvedActions: ->
    @resolvedActions = {}

  _resolve: (action, params) ->
    params = @_paramsFor action, _.toArray(params)
    @resolvedActions[action] = params

  _isResolved: (action, params) ->
    params = @_paramsFor action, _.toArray(params)
    _.isEqual @resolvedActions[action], params

  _paramsFor: (action, params) ->
    @reverseRoutes or= _.invert(@appRoutes)
    regex = /:[^/]+/g
    route = @reverseRoutes[action]
    numberOfParams = route.match(regex)?.length or 0
    params.slice(0, numberOfParams)

  _getDependencyArray: (action) ->
    dependencies = @dependencies?[action]
    dependencies = [dependencies] if typeof dependencies is "string"
    dependencies || []
