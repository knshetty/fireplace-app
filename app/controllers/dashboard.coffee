`import Ember from 'ember'`

DashboardController = Ember.Controller.extend (

    # -----------------------
    # --- Declare Globals ---
    # -----------------------
    previouslyMadeFire_Hour: null

    firePlan: { makeFire: null,  msg: null, startTime: null, woodCount: null }

    countdownEndDateime: null

    # ------------------------------
    # --- Declare Event Handlers ---
    # ------------------------------
    actions:
        updateModel: ->
            @get('theRoute').send('updateModel')

        showPlan: ->
            @set('firePlan', {
                    makeFire: true
                    msg: 'Make Fire'
                    startTime: '9:00'
                    woodCount: 9})

            @set('countdownEndDateime', @_generateEndDatetime_JSON_IncBySeconds(5))

            ###
            @set('firePlan', {
                    makeFire: false
                    msg: 'No Firemaking'
                    startTime: null
                    woodCount: null})###

        clearPlan: ->
            @set('firePlan', {
                makeFire: null
                msg: null
                startTime: null
                woodCount: null})

    # -----------------------------
    # --- Declare Local Methods ---
    # -----------------------------
    _generateEndDatetime_JSON_IncByHours: (hoursInFuture) ->
        timeNow = new Date()
        timeNow.setHours(timeNow.getHours() + hoursInFuture)
        return timeNow.toJSON()

    _generateEndDatetime_JSON_IncBySeconds: (secondsInFuture) ->
        timeNow = new Date()
        timeNow.setSeconds(timeNow.getSeconds() + secondsInFuture)
        return timeNow.toJSON()

    # -----------------------------------
    # --- Declare Computed Properties ---
    # -----------------------------------
    planEntry: ( ->
        @get('firePlan.msg') != null
    ).property('firePlan.msg')

    # -------------------------
    # --- Declare Observers ---
    # -------------------------
    previouslyMadeFireChanged: ( ->
        console.log @previouslyMadeFire_Hour
    ).observes('previouslyMadeFire_Hour')

)

`export default DashboardController`
