require "spec_helper"

def get_child_processes(pid)
  # Get the child pids.
  pipe = IO.popen("ps -ef | grep #{pid}")

  child_pids = pipe.readlines.map do |line|
    parts = line.split(/\s+/)
    parts[2] if parts[3] == pid.to_s and parts[2] != pipe.pid.to_s
  end.compact

  child_pids
end

describe "zeus-parallel_spec" do
  before(:all) do
    @zeus_master = fork do
      exec "cd spec/dummy && zeus start 2>/dev/null"
    end
    @processes = get_child_processes(@zeus_master)
  end

  after(:all) do
    @processes.each do |p|
      Process.kill "TERM", p.to_i
    end
  end

  it 'launches server' do
    system "cd spec/dummy && zeus rspec spec/good_spec.rb"
    expect($?.to_i).to be_zero
  end
end
