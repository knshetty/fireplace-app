`import Ember from 'ember'`

CountdownTimerComponent = Ember.Component.extend(

    tagName: 'small'

    attributeBindings: ['endDate']

    # ------------------------
    # --- Declare: Globals ---
    # ------------------------
    _countdownTimer : null

    _theController: null

    # -------------------------------------
    # Declare: Component Specific Functions
    # -------------------------------------
    didInsertElement: ->

        @set('_theController', @get('_controller'))

        context = @
        @_countdownTimer = @$().countdown({
                date: @endDate
                render: (data) ->
                  context.$(@el).text(
                    @leadingZeros(data.hours, 2) + " : " +
                    @leadingZeros(data.min, 2) + " : " +
                    @leadingZeros(data.sec, 2))
                onEnd: ->
                    context.$(@el).addClass('ended')
                    console.log 'EEEEEEEEEEEEEE'
                    context._theController.send('clearPlan')
            })

    # --------------------------
    # --- Declare: Observers ---
    # --------------------------
    endDateChanged: ( ->
        @_countdownTimer.removeClass('ended').data('countdown').update(@endDate).start()
    ).observes('endDate')

)

`export default CountdownTimerComponent`
