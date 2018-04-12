RSpec.shared_examples 'an app that uses .to have_no to test absence in feature tests' do
  subject { check_files_for_pattern(files, pattern) }

  context 'when pattern matching for `.not_to have_`' do
    let(:pattern) { /\.not_to[\s\(]have_/ }

    def inaccurate_visibility_assertion_message
      <<~ERROR_MESSAGE
        `.not_to have_` was used as an assertion in the following files.
        Feature tests should use `.to have_no`.
        This ensures that the page and DOM have loaded before asserting the absence of a component

        #{subject.join("\n")}
      ERROR_MESSAGE
    end

    context 'in feature spec files' do
      let(:files) { Rails.root.join('spec', 'features', '**', '*.rb') }

      it 'uses `.to have_no` assertions' do
        expect(subject).to be_empty, inaccurate_visibility_assertion_message
      end
    end

    context 'in shared example files' do
      let(:files) { Rails.root.join('spec', 'support', 'shared_examples', '**', '*.rb') }

      it 'uses `.to have_no` assertions' do
        expect(subject).to be_empty, inaccurate_visibility_assertion_message
      end
    end
  end

  context 'when pattern matching for `have_no_x wait: 0' do
    let(:pattern) { /have_no_\w+(\s+|\()wait: 0/ }

    def inaccurate_waiting_assertion_message
      <<~ERROR_MESSAGE
        `wait: 0` was used with a have_no_x assertion in the following files.
        Feature tests should wait for have_no assertions.
        This ensures that the page and DOM have loaded before asserting the absence of a component

        #{subject.join("\n")}
      ERROR_MESSAGE
    end

    context 'in feature spec files' do
      let(:files) { Rails.root.join('spec', 'features', '**', '*.rb') }

      it 'uses `have_no_x wait: 0` assertions' do
        expect(subject).to be_empty, inaccurate_waiting_assertion_message
      end
    end

    context 'in shared example files' do
      let(:files) { Rails.root.join('spec', 'support', 'shared_examples', '**', '*.rb') }

      it 'uses `have_no_x wait: 0` assertions' do
        expect(subject).to be_empty, inaccurate_waiting_assertion_message
      end
    end
  end
end
