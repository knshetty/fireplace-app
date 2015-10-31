`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'clock-n-outdoortemperatureforecast', 'Integration | Component | clock n outdoortemperatureforecast', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{clock-n-outdoortemperatureforecast}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#clock-n-outdoortemperatureforecast}}
      template block text
    {{/clock-n-outdoortemperatureforecast}}
  """

  assert.equal @$().text().trim(), 'template block text'
