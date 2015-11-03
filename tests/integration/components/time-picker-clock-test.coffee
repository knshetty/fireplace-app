`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'time-picker-clock', 'Integration | Component | time picker clock', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{time-picker-clock}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#time-picker-clock}}
      template block text
    {{/time-picker-clock}}
  """

  assert.equal @$().text().trim(), 'template block text'
