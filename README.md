# TestTrack

[![Build Status](https://travis-ci.org/Betterment/test_track.svg?branch=master)](https://travis-ci.org/Betterment/test_track)

TestTrack is an open-source split-testing and feature-toggling system written in Ruby on Rails.

The TestTrack system consists of the following components:

* the server (this repository)
* the [Rails client](https://github.com/Betterment/test_track_rails_client)
* the [JS client](https://github.com/Betterment/test_track_js_client)
* the [Chrome extension](https://github.com/Betterment/test_track_chrome_extension)

## Getting Started

### Requirements
The list of requirements to configure a TestTrack server are:
  * Ruby 2.2.3+
  * Postgresql 9.4+

### Installation
1. `git clone https://github.com/Betterment/test_track`
1. `bundle install`
1. `bundle exec rake db:setup`
1. `bundle exec rails server`

At this point, you've got a working installation and can proceed to setting up the [Rails client](https://github.com/Betterment/test_track_rails_client) in order to create your first split.

### Deployment
TestTrack is designed to deploy as a conventional [12-factor](https://12factor.net/) application.

Required environment variables:
* `DATABASE_URL` -- the url to your Postgresql database server

#### Configuration for JS Client
In order to use the JS client, you will need to specify the set of hosts that will be making CORS requests to your TestTrack server. That can be set via the `WHITELIST_CORS_HOSTS` environment variable.

```bash
export WHITELIST_CORS_HOSTS=yoursite.example.org,othersite.example.org
```

#### Configuration for Chrome extension
In order to use the TestTrack Chrome extension, you will need to set up the `BROWSER_EXTENSION_SHARED_SECRET` environment variable. [Details.](https://github.com/Betterment/test_track_chrome_extension#building-the-extension)

## Managing your installation
There are a few things that you will need to do in the TestTrack application:
* Create `App`s -- client applications that will manage splits on your TestTrack server
* Create `Admin`s -- users that can access the admin features of the TestTrack server
* Manage splits using the admin features

### Creating Apps
In order to create spilts in your client applications, you will need to register that client application with your TestTrack server. Run the following in a rails console.

```ruby
> App.create!(name: "[myapp]", auth_secret: SecureRandom.urlsafe_base64(32)).auth_secret
=> "[your new app password]"
```

This is the password that you should plug into your client application's `TEST_TRACK_API_URL`.

### Creating Admins
In order to access the admin features of the TestTrack server, you must create an `Admin` in your database. Run the following in a rails console.

```ruby
> Admin.create!(email: "myemail@example.org", password: "[something secret]")
```

## Concepts

## App
A Rails application that manages Splits on the TestTrack server.

## Admin
A member of your team that administers the weightings of splits, deciding a the winning variant of a split, and uploading one-off visitor assignments.

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
