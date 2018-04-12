RSpec.shared_examples "a Betterment application" do
  context "views" do
    subject { check_files_for_pattern(files, pattern) }
    let(:files) { Rails.root.join('app', 'views', '**', '*') }

    def error_text(pattern_text)
      <<-ERROR_MESSAGE
      `#{pattern_text}` was called in the following files.
      Consider rewriting to avoid using `#{pattern_text}` or move into a view helper.
      See more info here: https://betterconfluence.atlassian.net/wiki/display/BetterEng/Unsafe+HTML+rendering

      #{subject.join("\n")}
      ERROR_MESSAGE
    end

    context "when pattern matching for raw" do
      let(:pattern) { /(?<![a-zA-Z_-])raw(?![a-zA-Z_-])/ }

      it "doesn't call raw" do
        expect(subject).to be_empty, error_text('raw')
      end
    end

    context "when pattern matching for html_safe" do
      let(:pattern) { /(?<![a-zA-Z_-])html_safe(?![a-zA-Z_-])/ }

      it "doesn't call html_safe" do
        expect(subject).to be_empty, error_text('html_safe')
      end
    end

    context "when pattern matching for safe_concat" do
      let(:pattern) { /(?<![a-zA-Z_-])safe_concat(?![a-zA-Z_-])/ }

      it "doesn't call safe_concat" do
        expect(subject).to be_empty, error_text('safe_concat')
      end
    end

    context "when pattern matching for <%==" do
      let(:pattern) { Regexp.new("<%==") }

      it "doesn't use <%==" do
        expect(subject).to be_empty, error_text('<%==')
      end
    end
  end
end
