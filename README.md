# TestTrack

[![Build Status](https://magnum.travis-ci.com/Betterment/test_track.svg?token=sNaLMCvTggR3ihbnQ2GE&branch=master)](https://magnum.travis-ci.com/Betterment/test_track)

TestTrack is an open-source split-testing and feature-toggling system written in Ruby on Rails.

The TestTrack system consists of the following components:

* the server (this repository)
* the [Rails client](https://github.com/Betterment/test_track_rails_client)
* the [JS client](https://github.com/Betterment/test_track_js_client)
* the [Chrome extension](https://github.com/Betterment/test_track_chrome_extension)

## Getting Started
TODO

## Concepts

## Visitor
A person using your application.

## Split
A feature for which TestTrack will be assigning different behavior for different visitors.

Split names must be strings and should be expressed in `snake_case`. E.g. `homepage_redesign_late_2015_experiment`, `signup_button_color_experiment`, or `invite_button_enabled`.

## Variant
One the values that a given visitor will be assigned for a split, e.g. `true` or `false` for a classic A/B test or e.g. `red`, `blue`, and `green` for a multi-way split.  Variants may be strings or booleans, and they should be expressed in `snake_case`.

## Weighting
Variants are assigned pseudo-randomly to visitors based on their visitor IDs and the weightings for the variants.  Weightings describe the probability of a visitor being assigned to a given variant in integer percentages.  All the variant weightings for a given split must sum to 100, though variants may have a weighting of 0.

## IdentifierType
A name for a customer identifier that is meaningful in your application, typically things that people sign up as, log in as.  They should be expressed in `snake_case` and conventionally are prefixed with the application name that the identifier is for, e.g. `myapp_user_id`, `myapp_lead_id`.

## People using TestTrack
TODO

## Contributing
TODO
