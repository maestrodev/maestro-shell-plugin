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

  before(:all) do
    Maestro::MaestroWorker.mock!
  end

  before(:each) do
    FileUtils.rm '/tmp/shell.sh' if File.exists? '/tmp/shell.sh'
  end

  describe 'valid_workitem?' do
    it "should validate fields" do
      workitem = {'fields' =>{}}

      subject.perform(:execute, workitem)

      workitem['fields']['__error__'].should include('missing field command_string')
    end
  end

  describe 'execute' do
    before :all do
#      @workitem =  {'fields' => {'tasks' => '',
#                                 'path' => @path,
#                                 'ant_version' => '1.8.2'}}
    end

    it 'should return successfully with valid command' do
      command = 'touch /tmp/archive_test.tar.gz && ls -l /tmp/archive_test.tar.gz'
      workitem = {'fields' => {
        'command_string' => command, 
        'environment' => 'PATH=$PATH;'
      }}

      subject.perform(:execute, workitem)

      workitem['fields']['__error__'].should be_nil
      workitem['__output__'].should include("archive_test.tar.gz")
    end
    
    it 'should return successfully with invalid command' do
      command = 'ls -l /blahdy/'
      workitem = {'fields' => {
        'command_string' => command
      }}

      subject.perform(:execute, workitem)

      workitem['fields']['__error__'].should eq "Error executing shell task, exit code was 1"
      workitem['__output__'].should include "No such file or directory"
    end

    it 'should write the output to lucee' do
      command = 'echo my message'
      workitem = {'fields' => {
        'command_string' => command
      }}

      subject.perform(:execute, workitem)

      workitem['fields']['__error__'].should be_nil
      workitem['__output__'].should include("my message\n")
    end
  end
end
