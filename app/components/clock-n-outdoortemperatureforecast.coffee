`import Ember from 'ember'`

ClockNOutdoortemperatureforecastComponent = Ember.Component.extend (

  attributeBindings: ['weatherDataset', 'onUpdateWeather', 'fireMakingPlan']

  # ----------------
  # Declare: Globals
  # ----------------
  _temperatures_OrderedByAscendingHours: []

  _alltemperatureText_SvgObjs: null

  _makeFireIndicator_SvgObj: null

  # -------------------------------------
  # Declare: Component Specific Functions
  # -------------------------------------
  didInsertElement: ->
    # Tranform weather dataset
    @_tranform_WeatherDataset()

    # Create snap.svg context
    @_snapsvgInit()

    # Get handle to Clock svg
    s = @get('draw')

    # Manipulate Clock svg objects
    context = @
    Snap.load("assets/clock-n-temperature.svg", (f) ->

      # --- Get Clock svg objects ----
      secondNeedle = f.select("#second")
      minuteNeedle = f.select("#minute")
      hourNeedle = f.select("#hour")

      # --- Get all temperature-text svg objects ----
      futureRing = f.select("#seperator-now-n-future")
      temperatureTextObjs = []
      for i in [1..12]
        temperatureTextObjs.push(f.select("#tmp_#{i}"))
      context.set('_alltemperatureText_SvgObjs', temperatureTextObjs)

      # --- Get Make-Fire-Indicator svg objects ----
      makeFireIndicator = f.select("#start-fire-indicator")
      makeFireIndicator.attr({opacity: 0}) # Hide
      context.set('_makeFireIndicator_SvgObj', makeFireIndicator)

      # --- Make-Fire-Indicator Animation ---
      context._setMakeFireIndicatorObj()

      # Update all temperatures
      context._updateAllTemperatures()

      # Start Clock animation
      context._animateTime(secondNeedle, minuteNeedle, hourNeedle, futureRing)

      s.append(f)
    )

  # ------------------------
  # Declare: Local Functions
  # ------------------------
  _snapsvgInit: ->

    draw = Snap('#clock-n-outdoortemperatureforecast-wrapper')
    @set('draw', draw)

  _animateTime: (secondNeedle, minuteNeedle, hourNeedle, futureRing) ->

    # --- Get the current time ---
    timeNow = new Date()
    hours   = timeNow.getHours()
    minutes = timeNow.getMinutes()
    seconds = timeNow.getSeconds()

    # --- Positioning of Clock's objects ---
    clockCenterPosition = ',250,250'
    futureRingCenterPosition = ',200,200'

    # --- Second-Needle Animation ---
    # Move second-needle halfway
    secondNeedle.transform('r' + (seconds*6-97) + clockCenterPosition)
    # Animate the second-needle to its resting position
    secondNeedle.animate({transform: 'r' + (seconds*6-94) + clockCenterPosition}, 500, mina.elastic)

    # --- Minute-Needle Animation ---
    # Move minute-needle
    minuteNeedle.transform('r' + (minutes*6) + clockCenterPosition)
    # Only animate the minute needle when the minute changes
    if seconds == 0
        minuteNeedle.transform('r' + (minutes*6-3) + clockCenterPosition)
        minuteNeedle.animate({transform: 'r' + (minutes*6) + clockCenterPosition}, 500, mina.elastic)

    # --- Hour-Needle Animation ---
    # Move the hour-needle when the minutes change
    hourNeedle.transform('r' + ((hours*30)+(minutes/2)) + clockCenterPosition)

    # --- Future-Ring Animation ---
    offset_FutureRing = 20
    futureRing.transform('r' + ((hours*30) - offset_FutureRing + (minutes/2)) + futureRingCenterPosition)

    # --- Update all Temperatures ---
    # Update temperature every 30mins, starting at 3mins past the hour
    if (minutes == 3 and seconds == 0) or (minutes == 33 and seconds == 0)
        @get('onUpdateWeather')()
    ###
    if seconds == 1
        #@_updateAllMockTemperatures()
    ###

    # --- Repeat this entire routine every second ---
    context = @
    setTimeout ( ->
        context._animateTime(secondNeedle, minuteNeedle, hourNeedle, futureRing)
    ), 1000

  _tranform_WeatherDataset: ->

    # --- Transform: Arrange forecasted temperatures in ascending hourly order ---
    # Sort future temperatures
    for f in @weatherDataset.forecast
        @_insertTemperature_InAscendingHourlyOrder(f.localtime, f.temperature)
    # Sort current temperature
    @_insertTemperature_InAscendingHourlyOrder(@weatherDataset.current.observationallocaltime, @weatherDataset.current.temperature)

  _insertTemperature_InAscendingHourlyOrder: (localtime, temperature) ->

      # --- Get hour from the timestamp ---
      if localtime.search('T') != -1 # Handle Timestamp with following format: "20151025T020000"
          timestampParts = localtime.split('T')
          hour = timestampParts[1].substring(0,2)
      else # Handle Timestamp with following format: "201510242150"
          hour = localtime.substring(8,10)

      # --- Sort temperatures by ascending hourly order ---
      if hour is '00' or hour is 12
          @_temperatures_OrderedByAscendingHours[11] = temperature
      else if hour > 12
          @_temperatures_OrderedByAscendingHours[(hour-12)-1] = temperature
      else
          @_temperatures_OrderedByAscendingHours[hour-1] = temperature

  _updateAllTemperatures: ->
      for t, index in @_temperatures_OrderedByAscendingHours
          @_setTextObj(@_alltemperatureText_SvgObjs[index], t)

  _updateAllMockTemperatures: ->

    forcast_temperature = []
    for i in [1..12]
        forcast_temperature.push(@_getRandomNumInRange(-15,15))
    for t, index in forcast_temperature
        @_setTextObj(@_alltemperatureText_SvgObjs[index], t)

  _getRandomNumInRange: (min,max) ->

    length = (max-min) + 1
    rValue = Math.floor(Math.random()*length)
    min + rValue

  _setTextObj: (temperatureTextObj, text) ->

    temperatureTextObj.selectAll('tspan')[0].node.textContent = text

  _setMakeFireIndicatorObj: ->
    if @fireMakingPlan.makeFire
        @_makeFireIndicator_SvgObj.attr({opacity: 1}) # Unhide
        fireMakingHour = @fireMakingPlan.startTime.split(':')[0].substring(0,2)
        @_makeFireIndicator_SvgObj.transform('r' + ((fireMakingHour*30)) + ',200,200')
    else
        @_makeFireIndicator_SvgObj.attr({opacity: 0}) # Hide

  # ------------------------------
  # --- Declare Event Handlers ---
  # ------------------------------
  ###
  actions:
  ###

  # -------------------------
  # --- Declare Observers ---
  # -------------------------
  weatherdataChanged: ( ->
    @_tranform_WeatherDataset()
    if @_alltemperatureText_SvgObjs
        @_updateAllTemperatures()
  ).observes('weatherDataset')

  fireMakingPlanChanged: ( ->
    @_setMakeFireIndicatorObj()
  ).observes('fireMakingPlan')

)

`export default ClockNOutdoortemperatureforecastComponent`
