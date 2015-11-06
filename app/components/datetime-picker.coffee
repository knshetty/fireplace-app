`import Ember from 'ember'`

DatetimePickerComponent = Ember.Component.extend(

    tagName: 'div'

    classNames: ['input-group', 'date', 'form_datetime']

    attributeBindings: ['valueholder', 'placeholder', 'disableflag']

    # -------------------------------------
    # Declare: Component Specific Functions
    # -------------------------------------
    didInsertElement: ->

        Ember.$('#datetimepickerInput').datetimepicker(
            format: "hh - dd/mm/yyyy"
            showMeridian: true
            autoclose: true
            todayBtn: true
            startView: 'day'
            minView: 'day'
        )

    actions:
        clear: ->
            @set('valueholder', null)

)

`export default DatetimePickerComponent`
