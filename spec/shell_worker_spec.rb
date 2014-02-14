# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#  http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require 'spec_helper'

describe MaestroDev::Plugin::ShellWorker do

  let(:command) { 'ls -l /blahdy/' }
  let(:workitem) {{ 'fields' => fields }}
  let(:fields) {{ 'command_string' => command }}

  before(:all) do
    Maestro::MaestroWorker.mock!
  end

  before(:each) do
    FileUtils.rm '/tmp/shell.sh' if File.exists? '/tmp/shell.sh'
    subject.perform(:execute, workitem)
  end

  describe 'valid_workitem?' do
    context "when fields are empty" do
      let(:fields) {{}}
      its(:error) { should include('missing field command_string') }
    end
  end

  describe 'execute' do

    context 'when using a valid command' do
      let(:command) { 'touch /tmp/archive_test.tar.gz && ls -l /tmp/archive_test.tar.gz' }
      let(:fields) { super().merge({'environment' => 'PATH=$PATH;'}) }
      its(:error) { should be_nil }
      its(:output) { should include("archive_test.tar.gz") }
    end
    
    context 'when running an invalid command' do
      let(:command) { 'ls -l /blahdy/' }
      its(:error) { should match(/^Error executing shell task, exit code was \d$/) }
      its(:output) { should include "No such file or directory" }
    end

    context 'when writing output to lucee' do
      let(:command) { 'echo my message' }
      its(:error) { should be_nil }
      its(:output) { should include("my message\n") }
    end
  end
end
