require 'fileutils'
require 'open3'
require 'timeout'

RSpec::Matchers.define :become_true do |expected|

  match do |block|
    end_time = Time.now + Capybara.default_wait_time.seconds 
    loop do
      break if Time.now > end_time
      value = block.call
      return true if value
    end
    false
  end

  def supports_block_expectations?
    true
  end

end

SnapshotInfo = Struct.new(:name, :variation, :file)

class RSpec::Core::ExampleGroup

  def snapshot(name = :default, variation = :desktop)
    tmp = Tempfile.new([variation, '.png'])
    tmp.close

    document_width = page.driver.evaluate_script("document.documentElement.clientWidth")
    document_height = page.driver.evaluate_script("document.documentElement.clientHeight")
    page.save_screenshot "#{tmp.path}", width: document_width, height: document_height

    SnapshotInfo.new(name, variation, tmp)
  end

end

RSpec.configure do |config|
  config.after(:example) do |example|
    msg = example.metadata[:new_snapshot_paths].inject('') do |msg, path|
      <<-COMMANDS #{msg}
Show new screenshot:
  $ open #{dirname}/NEW_#{path}

Approve new screenshot:
  $ mv #{dirname}/NEW_#{path} #{dirname}/#{path}
COMMANDS
    end unless example.metadata[:new_snapshot_paths].nil?

    raise RSpec::Expectations::ExpectationNotMetError, msg, example.metadata[:snapshot_first_caller] unless msg.blank?
  end

  def dirname
    'spec/support/expected_snapshots'
  end

end

RSpec::Matchers.define :look_correct do
  match do |snapshot_info|

    next true if ENV['SKIP_SCREENSHOT_DIFF']

    path = snapshot_path(snapshot_info)

    existing_path = "#{dirname}/#{path}"
    new_path = snapshot_info.file.path

    existing_height = height_of(existing_path)
    new_height = height_of(new_path)

    tmpfile_path = Tempfile.new(['scaled','.png']).path if existing_height != new_height

    if existing_height < new_height
      `convert #{existing_path} -resize 1650x#{new_height} -background black -compose Copy -gravity north -extent 1650x#{new_height} #{tmpfile_path}`
      existing_path = tmpfile_path
    end

    if new_height < existing_height
      `convert #{new_path} -resize 1650x#{existing_height} -background black -compose Copy -gravity north -extent 1650x#{existing_height} #{tmpfile_path}`
      new_path = tmpfile_path
    end


    if File.exists?(existing_path)
      prog = 'compare'
      args = '-verbose -metric RMSE -highlight-color Red'
      diff_path = "#{dirname}/DIFF_#{path}"

      # do image comparison
      cmd = "#{prog} #{args} \"#{existing_path}\" \"#{new_path}\" \"#{diff_path}\""
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        thr_status = wait_thr.value

        case thr_status.exitstatus
          when 0
            # remove the diff image since the images match
            FileUtils.rm(diff_path)
          when 1
            # images are different
            FileUtils.mv(snapshot_info.file.path, "#{dirname}/CHANGED_#{path}")
            false
          else
            puts stdout.read
            puts stderr.read
            raise "Diff command failed #{cmd} : (#{thr_status.exitstatus})"
        end
      end
    else

      # this is a new screenshot, so move it in place
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      FileUtils.mv(snapshot_info.file.path, "#{dirname}/NEW_#{path}")

      example.metadata[:snapshot_first_caller] = caller unless example.metadata[:snapshot_first_caller]
      (example.metadata[:new_snapshot_paths] ||= []) << path
    end
  end

  failure_message do |snapshot_info|
    path = snapshot_path(snapshot_info)

<<-COMMANDS
expected that '#{snapshot_info.name}' screenshot for #{snapshot_info.variation} would look correct

Show screenshot diffs:
  $ open #{dirname}/DIFF_#{path} #{dirname}/CHANGED_#{path} #{dirname}/#{path}

Approve changed screenshot:
  $ mv #{dirname}/CHANGED_#{path} #{dirname}/#{path}
COMMANDS
  end

  def dirname
    'spec/support/expected_snapshots'
  end

  def snapshot_path(snapshot_info)
    "#{[example.metadata[:full_description].parameterize('-'), snapshot_info.name, snapshot_info.variation].join('_')}.png"
  end

  def height_of(path)
    `identify -format "%h" #{path}`.chomp.to_i
  end

  def example
    RSpec.current_example
  end
end
