`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'datetime-picker', 'Integration | Component | datetime picker', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{datetime-picker}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#datetime-picker}}
      template block text
    {{/datetime-picker}}
  """

  assert.equal @$().text().trim(), 'template block text'
