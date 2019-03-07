require 'rails_helper'

RSpec.describe SplitCreation do
  let(:default_app) { FactoryBot.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU" }

  let(:bad_weather) { { rain: 20, snow: 20, hurricane: 60 }.stringify_keys }
  let(:bad_weather_create) { SplitCreation.new(app: default_app, name: "weather", weighting_registry: bad_weather) }

  let(:good_weather) { { clear_skies: 100 }.stringify_keys }
  let(:good_weather_create) { SplitCreation.new(app: default_app, name: "weather", weighting_registry: good_weather) }

  it 'creates a new split config for a new name' do
    expect(Split.find_by(name: "amazing")).to be_falsey
    SplitCreation.create(app: default_app, name: "amazing", weighting_registry: { awesome: 100 })
    expect(Split.find_by(name: "amazing", feature_gate: false)).to be_truthy
  end

  it 'creates feature gates when name ends in _enabled' do
    expect(Split.find_by(name: "foo_enabled")).to be_falsey
    SplitCreation.create(app: default_app, name: "foo_enabled", weighting_registry: { awesome: 100 })
    expect(Split.find_by(name: "foo_enabled", feature_gate: true)).to be_truthy
  end

  it 'updates existing split config for a known name' do
    expect(Split.find_by(name: "weather")).to be_falsey

    bad_weather_create.save
    good_weather_create.save

    weather = Split.find_by(name: "weather")

    expect(weather.registry.symbolize_keys).to eq rain: 0, snow: 0, clear_skies: 100, hurricane: 0
  end

  it 'reenables a finished split' do
    bad_weather_create.save
    Split.find_by!(name: "weather").update!(finished_at: Time.zone.now)
    good_weather_create.save

    weather = Split.find_by(name: "weather")
    expect(weather.finished_at).to be_nil
  end

  it 'delegates validation errors to split' do
    split_creation = SplitCreation.new(app: default_app, name: "bad_test", weighting_registry: { badBadBad: 100 })
    expect(split_creation.save).to eq false
    expect(split_creation.errors[:name].first).to include("redundant")
    expect(split_creation.errors[:weighting_registry].first).to include("snake_case")
  end

  context 'when updating existing split' do
    it 'noops when the weights have not changed' do
      weather = Split.find_by(name: "weather")
      expect(weather).to be_falsey

      bad_weather_create.save

      weather = Split.find_by(name: "weather")
      expect(weather.previous_split_registries.size).to eq 0
      expect(weather.registry.symbolize_keys).to eq rain: 20, snow: 20, hurricane: 60

      bad_weather_create.save

      weather = Split.find_by(name: "weather")
      expect(weather.previous_split_registries.size).to eq 0
      expect(weather.registry.symbolize_keys).to eq rain: 20, snow: 20, hurricane: 60
    end

    it 'archives removed variants, using a weight of 0' do
      expect(Split.find_by(name: "weather")).to be_falsey

      bad_weather_create.save
      weather = Split.find_by(name: "weather")

      expect(weather.registry.symbolize_keys).to eq rain: 20, snow: 20, hurricane: 60

      good_weather_create.save
      weather.reload
      expect(weather.registry.symbolize_keys).to eq rain: 0, snow: 0, hurricane: 0, clear_skies: 100
    end

    it 'marks previous variant weighting as superseded' do
      expect(Split.find_by(name: "weather")).to be_falsey

      bad_weather_create.save
      weather = Split.find_by(name: "weather")

      good_weather_create.save

      weather.reload
      prev_split_registry = weather.previous_split_registries.order(superseded_at: :desc).first

      expect(prev_split_registry.registry).to eq(bad_weather)
      expect(weather.registry).to eq({ hurricane: 0, rain: 0, snow: 0, clear_skies: 100 }.stringify_keys)
      expect(weather.updated_at).to eq(prev_split_registry.superseded_at)
    end
  end
end
