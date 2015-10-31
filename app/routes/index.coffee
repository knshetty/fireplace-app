`import Ember from 'ember'`

IndexRoute = Ember.Route.extend (

    redirect: ->
        @transitionTo('dashboard')

)

`export default IndexRoute`
