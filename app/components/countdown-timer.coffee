`import Ember from 'ember'`

CountdownTimerComponent = Ember.Component.extend(

    tagName: 'small'

    attributeBindings: ['endDate', 'onCountdownEnded']

    # ------------------------
    # --- Declare: Globals ---
    # ------------------------
    _countdownTimer : null

    # -------------------------------------
    # Declare: Component Specific Functions
    # -------------------------------------
    didInsertElement: ->
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
                    context.get('onCountdownEnded')()
            })

    # --------------------------
    # --- Declare: Observers ---
    # --------------------------
    endDateChanged: ( ->
        @_countdownTimer.removeClass('ended').data('countdown').update(@endDate).start()
    ).observes('endDate')

)

`export default CountdownTimerComponent`
