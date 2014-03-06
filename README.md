# Backbone Dependency Router

There's a common scenario where the following routes are defined

    "/widgets"    : "index"
    "/widgets:id" : "show"

When navigating from */widgets* to */widgets/1*, only the "show" action should be run.  (The index is still displayed and we should not waste resources redrawing it.)

But when the browser is refreshed, both "index" and "show" need to run.

As routes are nested deeper, managing this dependency tree can get increasingly convoluted.

# Defining Dependencies

DependencyRouter manages this hierarchy for you.

    class BlogRouter extends Backbone.Marionette.DependencyRouter
      appRoutes:
        "posts"                       : "index"
        "posts/:id"                   : "show"
        "posts/:postId/comments"      : "comments"
        "posts/:postId/comments/:id"  : "showComment"

      dependencies:
        "show"        : "index"
        "comments"    : ["show", "index"]
        "showComment" : ["comments", "show", "index"]

Now, routing directly to */posts/1/comments/2* will run the actions:

    * showComment(1, 2)
    * comments(1)
    * show(1)
    * index

And when navigating to */posts/1/comments/4* the only action that will be run is:

    * showComment(1, 4)

*In order to clear the router's state correctly, all routers in your application that will close a region or view managed by the Dependency Router need to derive from Dependency Router*

# Configuration

You must tell Backbone.Marionette.DependencyRouter where it can find an instance of Backbone.Wreqr.

If using Marionette (and Marionette's Module System)

    Backbone.Marionette.DependencyRouter.prototype.vent = App.vent

otherwise:

    Backbone.Marionette.DependencyRouter.prototype.vent = App.vent


### Dependencies

 * Backbone
 * Backbone.Marionette
 * Backbone.RouteFilter
