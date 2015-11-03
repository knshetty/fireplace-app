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
        showPlan: ->
            @set('firePlan', {
                    makeFire: true
                    msg: 'Make Fire'
                    startTime: '9:00'
                    woodCount: 9})

            timeNow = new Date()
            threeHoursInTheFuture = timeNow.getHours() + 3
            timeNow.setHours(threeHoursInTheFuture)
            @set('countdownEndDateime', timeNow.toJSON())

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
