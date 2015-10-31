`import Ember from 'ember'`

ClockNOutdoortemperatureforecastComponent = Ember.Component.extend (

  # ----------------
  # Declare: Globals
  # ----------------
  _theController: null

  _weatherdata: null

  _temperatures_OrderedByAscendingHours: []

  _alltemperatureText_SvgObjs: null

  # -------------------------------------
  # Declare: Component Specific Functions
  # -------------------------------------
  didInsertElement: ->

    # Get controller
    @set('_theController', @get('_controller'))

    # Extract & Tranform weather data
    @_extractAndTranform_WeatherData()

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
    if (minutes == 3 and seconds == 0) or (minutes == 33 and seconds == 0)
        @_theController.send('updateModel')
    ###
    if seconds == 1
        #@_updateAllMockTemperatures()
    ###

    # --- Repeat this entire routine every second ---
    context = @
    setTimeout ( ->
        context._animateTime(secondNeedle, minuteNeedle, hourNeedle, futureRing)
    ), 1000

  _extractAndTranform_WeatherData: ->

    # Extract: Get weather data
    @set('_weatherdata', @_theController.get('model'))

    # --- Transform: Arrange forecasted temperatures in ascending hourly order ---
    # Sort future temperatures
    for f in @_weatherdata.forecast
        @_insertTemperature_InAscendingHourlyOrder(f.localtime, f.temperature)
    # Sort current temperature
    @_insertTemperature_InAscendingHourlyOrder(@_weatherdata.current.observationallocaltime, @_weatherdata.current.temperature)

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

  # -------------------------
  # --- Declare Observers ---
  # -------------------------
  weatherdataChanged: ( ->
    @_extractAndTranform_WeatherData()
    if @_alltemperatureText_SvgObjs
        @_updateAllTemperatures()
  ).observes('_theController.model')

)

`export default ClockNOutdoortemperatureforecastComponent`
