`import Ember from 'ember'`

DashboardController = Ember.Controller.extend (

    # -----------------------
    # --- Declare Globals ---
    # -----------------------
    previouslyMadeFire_Hour: null

    firePlan: { makeFire: null,  msg: null, startTime: null, woodCount: null }

    countdownEndDateime: null

    temperatureHourSeries: []

    # ------------------------------
    # --- Declare Event Handlers ---
    # ------------------------------
    actions:
        updateModel: ->
            @get('theRoute').send('updateModel')

        showPlan: ->
            @generateFireMakingPlan()

        clearPlan: ->
            @set('firePlan', {
                    makeFire: null
                    msg: null
                    startTime: null
                    woodCount: null})

    # -----------------------------
    # --- Declare Local Methods ---
    # -----------------------------
    _getPreviouslyMadeFireDatetimeAsValue: ->
        # --- Parse following datetime format: 15 - 05/11/2015 ---
        timestampParts = @previouslyMadeFire_Hour.split(' - ')
        hours = timestampParts[0].substring(0,2)
        day = timestampParts[1].substring(0,2)
        month = timestampParts[1].substring(3,5)
        year = timestampParts[1].substring(6,10)

        # Instantiating Data-Obj >> Date(year, month(0..11), day, hours, minutes, seconds, milliseconds)
        previousFireHour_Datetime = new Date(year, month-1, day, hours)

        # --- Convert datetime to value
        return previousFireHour_Datetime.valueOf()

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

    maxFireboxLoad: ( ->
        @get('firePlan.woodCount') >= 25
    ).property('firePlan.woodCount')

    # -------------------------
    # --- Declare Observers ---
    # -------------------------
    onModelChanged: ( ->
        @generateFireMakingPlan()
    ).observes('model')

    previouslyMadeFireChanged: ( ->
        if (@previouslyMadeFire_Hour is null) or (@previouslyMadeFire_Hour)
            @send('updateModel')
    ).observes('previouslyMadeFire_Hour')

    # -----------------------------------------
    # --- Declare Weather-Analytics Methods ---
    # -----------------------------------------
    generateFireMakingPlan: ->
        # --- Trigger firemaking plan >> Only if previously-made-fire is older than 11hours --
        if @previouslyMadeFire_Hour
            timeNow = new Date().valueOf()
            elevenHours = 39600000
            if timeNow >= (@_getPreviouslyMadeFireDatetimeAsValue() + elevenHours)
                console.log '>> Intraday Firemaking Plan ---'
                extraFirewood = 0 # Due to intraday-start (i.e. 11hours gap between firemaking/heating)
                @planFireMaking(extraFirewood)
            else
                # --- Populate the Fireplan ---
                @set('firePlan', {
                        makeFire: false
                        msg: 'Fireplace Still Warm'
                        startTime: null
                        woodCount: null})
                @set('countdownEndDateime', @_generateEndDatetime_JSON_IncBySeconds(5))

        # --- Trigger firemaking plan >> Only if previously-made-fire is not declared --
        else if @previouslyMadeFire_Hour is null
            console.log '>> Cold-start Firemaking Plan ---'
            extraFirewood = 1 # Due to cold-start (i.e. unknown gap between firemaking/heating)
            @planFireMaking(1)

    planFireMaking: (extraFirewood)->
        # ------------------------
        # Trigger Settings
        # ------------------------
        temperatureThreshold = 6 # Trigger-threshold >> Over this threshold, indicate's low indoor temperature
        humidityThreshold = 79.5 # Trigger-threshold >> Over this threshold, indicate's high relative humidity
        hourlyForecastsSize = 3 # Falling-Edge indicator threshold >> Sequence of hourly forecasts, that will determined as a falling edge indicator
        firewoodToTemperatureRatio = '10:2' # Base-Model to calculate quantity-of-firewood to burn

        # Acquire present relative humidity in %
        relativeHumidity = @model.current.humidity

        # Calculate temperature-threshold: Alter the trigger temperature based on present humidity level
        qualifierTemperature = if relativeHumidity > humidityThreshold then temperatureThreshold else temperatureThreshold-1

        # --- Falling-Edge Indicator: Analyse if hourly forecasts is a falling edge ---
        # Note! First hour of the falling edge determines the hour-to-commence-heating
        bst = BinarySearchTree.create()
        hourToStartHeating = {key: null, value: null}
        for f in @temperatureHourSeries
            if bst.size() < hourlyForecastsSize
                if f.temperature <= qualifierTemperature
                    bst.add(f.temperature, parseInt(f.localtime,10))
                else if bst.size() > 0
                    bst.remove(bst.root.id, bst.root.key)
            else
                if bst.size() is hourlyForecastsSize
                    hourToStartHeating = {key: bst.root.key, value: bst.root.value}
                break

        # --------------------------------------------------------------------------
        # Generate Fire-making plan: When to makefire & quantity of firewood to burn
        # --------------------------------------------------------------------------
        # --- On Falling-Edge indicator being true ----
        if hourToStartHeating.key != null and hourToStartHeating.value != null
            # --- Get the lowest temperature in hourly forecasts ---
            lowestTemperatureInRange = hourToStartHeating.key
            for f in @temperatureHourSeries
                if f.temperature < lowestTemperatureInRange
                    lowestTemperatureInRange = f.temperature

            # --- Calculate the quantity of firewood to burn ---
            ratioParts = firewoodToTemperatureRatio.split(':')
            firewoodQuantRatio = parseInt(ratioParts[0], 10)
            temperatureRatio = parseInt(ratioParts[1], 10)
            firewoodQuantity = ((temperatureRatio - lowestTemperatureInRange) + firewoodQuantRatio) + extraFirewood

            # --- Populate the Fireplan ---
            @set('firePlan', {
                    makeFire: true
                    msg: 'Make Fire'
                    startTime: "#{hourToStartHeating.value}:00"
                    woodCount: firewoodQuantity})
            #@set('countdownEndDateime', @_generateEndDatetime_JSON_IncBySeconds(5))
        # --- On Falling-Edge indicator being false ---
        else
            # --- Populate the Fireplan ---
            @set('firePlan', {
                    makeFire: false
                    msg: 'No Firemaking'
                    startTime: null
                    woodCount: null})
            #@set('countdownEndDateime', @_generateEndDatetime_JSON_IncBySeconds(5))

)

Node = Ember.Object.extend()

BinarySearchTree = Ember.Object.extend(

    root: null

    add: (key, value) ->
        # Create a new node with no relatives
        #node = new Node(null, key, value, null, null)
        node = Node.create(
            id: null
            key: key
            value: value
            right: null
            left: null
        )

        # --- Populate Root-node ---
        if @root is null
            node.id = 1
            @root = node

        # --- Traverse binary tree & inject a new node ---
        else
            current = @root
            while true
                if key < current.key
                    # --- Inject a new left child-node ----
                    if current.left is null
                        node.id = @size() + 1
                        current.left = node
                        break
                    # --- Go to next left child-node ---
                    else
                        current = current.left

                else if key >= current.key
                    # --- Inject a new right child-node ---
                    if current.right is null
                        node.id = @size() + 1
                        current.right = node
                        break
                    # --- Go to next right child-node ---
                    else
                        current = current.right

                else
                    break

    remove: (id, key) ->
        found = false
        parent = null
        current = @root

        # --- Locate the node to be removed ---
        while not found and current?
            if key < current.key
                parent = current
                current = current.left
            else if (key >= current.key) and (id isnt current.id)
                parent = current
                current = current.right
            else if id is current.id
                found = true

        if found
            childCount = (if current.left isnt null then 1 else 0) + (if current.right isnt null then 1 else 0)

            if current is @root
                switch childCount
                    when 0
                        @root = null
                        break
                    when 1
                        @root = if current.right is null then current.left else current.right
                        break
                    when 2
                        replacement = @root.left

                        while replacement.right isnt null
                            replacementParent = replacement
                            replacement = replacement.right

                        if ((replacementParent is null) or (replacementParent is undefined))
                            replacement.right = @root.right
                        else
                            replacementParent.right = replacement.left
                            replacement.right = @root.right
                            replacement.left = @root.left

                        @root = replacement

            else
                switch childCount
                    when 0
                        if current.key < parent.key
                            parent.left = null
                        else
                            parent.right = null
                        break
                    when 1
                        if current.key < parent.key
                            parent.left = if current.left is null then current.right else current.left
                        else
                            parent.right = if current.left is null then current.right else current.left
                        break
                    when 2
                        replacement = current.left
                        replacementParent = current

                        while replacement.right isnt null
                            replacementParent = replacement
                            replacement = replacement.right

                        replacementparent.right = replacement.left

                        replacement.right = current.right
                        replacement.left = current.left
                        if current.key < parent.key
                            parent.left = replacement
                        else
                            parent.right = replacement

    traverse_inorder: (process) ->
        inOrder = (node) ->
            if node
                if node.left
                    inOrder(node.left)

                process.call(@, node)

                if node.right
                    inOrder(node.right)

        inOrder(@root)

    toArray: ->
        result = []
        @traverse_inorder (node) ->
            result.push("#{node}")
        result

    size: ->
        length = 0
        @traverse_inorder (node) ->
            length++
        length

)

`export default DashboardController`
