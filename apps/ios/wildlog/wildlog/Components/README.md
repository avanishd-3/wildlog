# Components

## Form Components

The default iOS form manages its own scrollability, meaning if you have both form and non-form content, the form part will scroll on its own,
instead of scrolling the whole page.

This pattern is most common when you have a form that is a list of links.

The custom form wraps this in a familiar interface, allowing the entire page to scroll at once.

Only use this if you have this use case. If the entire page is a form, use the default form.