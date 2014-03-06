expect = chai.expect
vent = new Backbone.Wreqr.EventAggregator()
Backbone.Marionette.DependencyRouter::vent = vent

#= require support/spec_helper
class NetworkRouter extends Backbone.Marionette.DependencyRouter
  appRoutes:
    "networks"     : "index"
    "networks/:id" : "show"

class VMRouter extends Backbone.Marionette.DependencyRouter
  appRoutes:
    "vms"                              : "index"
    "vms/:id"                          : "show"
    "vms/:fooId/volumes/:id"           : "showVolume"
    "vms/:fooId/volumes/:id/snap_pol"  : "policy"
    "vms/:fooId/volumes/:id/snapshots" : "listSnapshots"

  dependencies:
    "show"          : "index"
    "showVolume"    : ["show", "index"]
    "listSnapshots" : ["index", "showVolume", "policy", "show", "index"]

visit = (route) -> Backbone.history.navigate(route, { trigger: true })

describe "Backbone.Marionette.DependencyRouter", ->
  beforeEach ->
    @showSpy       = sinon.spy()
    @indexSpy      = sinon.spy()
    @showVolumeSpy = sinon.spy()

    @router = new VMRouter
      controller:
        index:                       => @indexSpy()
        show: (id)                   => @showSpy(id)
        showVolume: (vmId, volumeId) => @showVolumeSpy(volumeId)
        listSnapshots: ->
        policy: ->

    new NetworkRouter
      controller:
        index:  ->
        show:   ->

    Backbone.history.start({pushState: true, silent: true} )
    visit "networks"

  afterEach -> Backbone.history.stop()

  describe "#clearDependenciesNotFor", ->
    beforeEach ->
      @router.resolvedActions = { index: {}, show: 3 }

    describe "for a route with no dependencies", ->
      beforeEach -> @router._getDependencyArray = -> []

      it "clears the dependency array", ->
        @router.clearDependenciesNotFor("show")
        expect(@router.resolvedActions).to.deep.equal {}

    describe "for a route with overlapping dependencies", ->
      beforeEach ->
        @router._getDependencyArray  = -> ['index']
        @router.isCurrentRouter = -> true

      it "removes dependencies the action doesnt have", ->
        @router.clearDependenciesNotFor("show")
        expect(@router.resolvedActions).to.deep.equal { index: {} }

  it "can get arguments for a route", ->
    expect(@router._paramsFor("show", ['abc', '123'])).to.deep.equal ['abc']

  it "it passes in the arguments", ->
    visit "vms/123/volumes/456"
    expect(@showSpy.calledWith("123")).to.be.true

  it "runs a dependency block", ->
    visit "vms/abc-123"
    expect(@showSpy.called).to.be.true
    expect(@indexSpy.called).to.be.true

  it "doesn't rerun dependencies", ->
    visit "vms/123"
    visit "vms/321"
    expect(@indexSpy.calledOnce).to.equal true, 'indexSpy called once'
    expect(@showSpy.calledTwice).to.equal true, 'showSPy called twice'

  it "handles nested dependencies", ->
    visit "vms/123/volumes/8000"
    visit "vms/123/volumes/8001"
    visit "vms/999/volumes/9000"

    expect(@indexSpy.calledOnce).to.equal true
    expect(@showSpy.calledTwice).to.equal true

  it "invalidates cache when visiting another router", ->
    visit "vms"
    visit "networks"
    visit "vms/123"
    expect(@indexSpy.calledTwice).to.be.true

  it "doesn't run routes it doesn't need to", ->
    visit "vms/599/volumes/999"
    visit "vms/599"
    expect(@showSpy.calledOnce).to.be.true
    expect(@indexSpy.calledOnce).to.be.true

  it "counts actions navigated to directly", ->
    visit "vms"
    visit "vms/123"
    expect(@indexSpy.calledOnce).to.equal true
