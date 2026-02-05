# Components

## Form Components

The default iOS form manages its own scrollability, meaning if you have both form and non-form content, the form part will scroll on its own,
instead of scrolling the whole page.

This pattern is most common when you have a form that is a list of links.

The custom form wraps this in a familiar interface, allowing the entire page to scroll at once.

Only use this if you have this use case. If the entire page is a form, use the default form.

## Map Components

The default map over-rides the tab color, and it's quite limited, so we need to use UI Kit. UI Kit is equivalent to the iOS 17+ Map API, it's just more verbose. In fact, the iOS 17+ Map API is just an abstraction over UI Kit.

For more information on this and the approach to combat it: https://stackoverflow.com/questions/79502649/swiftui-tabbar-appearance-doesnt-work-in-only-those-views-which-have-map

The custom MKMap view is where the actual map interface is provided. We need to have one, because Apple does not provide a simple way to move the compass position with the regular MKMapView.

The Map View Representable component customizes the Map View, providing buttons and setting the controls the user is allowed to do.

The custom map view is just wrapping the map view representable into a VStack.

We will have to use this quite a bit, especially because maps are a prominent part of our app.

## Summary

| Component(s) | Style   |
| ------------ | ------- |
| Form         | SwiftUI |
| Map          | UI Kit  |
