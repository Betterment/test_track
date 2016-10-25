RSpec.shared_examples "a Betterment application" do
  context "views" do
    it "doesn't call raw" do
      result = `cd "#{Rails.root}" && find app/views | xargs ack -l "(?<![a-zA-Z_-])raw(?![a-zA-Z_-])" | sort | uniq`
      fail <<-EOF unless result.blank?
`raw` was called in the following files.
Consider rewriting to avoid using `raw` or move into a view helper.

#{result}
      EOF
    end

    it "doesn't call html_safe" do
      result = `cd "#{Rails.root}" && find app/views | xargs ack -l "(?<![a-zA-Z_-])html_safe(?![a-zA-Z_-])" | sort | uniq`
      fail <<-EOF unless result.blank?
`html_safe` was called in the following files.
Consider rewriting to avoid using `html_safe` or move into a view helper.

#{result}
      EOF
    end

    it "doesn't call safe_concat" do
      result = `cd "#{Rails.root}" && find app/views | xargs ack -l "(?<![a-zA-Z_-])safe_concat(?![a-zA-Z_-])" | sort | uniq`
      fail <<-EOF unless result.blank?
`safe_concat` was called in the following files.
Consider rewriting to avoid using `safe_concat` or move into a view helper.

#{result}
      EOF
    end

    it "doesn't use <%==" do
      result = `cd "#{Rails.root}" && find app/views | xargs ack -l "<%==" | sort | uniq`
      fail <<-EOF unless result.blank?
`<%==` was used in the following files:
Consider rewriting to avoid using `<%==`.

#{result}
      EOF
    end
  end
end
