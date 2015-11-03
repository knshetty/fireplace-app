`import Ember from 'ember'`

TimePickerClockComponent = Ember.Component.extend(

    tagName: 'div'

    classNames: ['input-group']

    attributeBindings: ['valueholder', 'placeholder', 'disableflag']

    # -------------------------------------
    # Declare: Component Specific Functions
    # -------------------------------------
    didInsertElement: ->

        Ember.$('#clockpickerInput').clockpicker({
            autoclose: true
            afterHourSelect: ->
                Ember.$('#clockpickerInput').clockpicker('done')
        })

    actions:
        clear: ->
            @set('valueholder', null)

)

`export default TimePickerClockComponent`
