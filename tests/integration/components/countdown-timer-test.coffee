`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'countdown-timer', 'Integration | Component | countdown timer', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{countdown-timer}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#countdown-timer}}
      template block text
    {{/countdown-timer}}
  """

  assert.equal @$().text().trim(), 'template block text'
