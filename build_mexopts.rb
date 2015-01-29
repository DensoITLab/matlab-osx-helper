#!/usr/bin/env ruby
#
#  build_mexopts.rb
#
# Copyright (c) 2015, Yuichi YOSHIDA, Denso IT Laboratory, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of matlab-osx-helper nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'rubygems'

class SDKInfo
  def initialize(sdkVersion, path, platformVersion, platformPath, productBuildVersion, productCopyright, productName, productVersion)
    @SDKVersion = sdkVersion
    @path = path
    @platformVersion = platformVersion
    @platformPath = platformPath
    @productBuildVersion = productBuildVersion
    @productCopyright = productCopyright
    @productName = productName
    @productVersion = productVersion
  end
  attr_accessor :SDKVersion, :path, :platformVersion, :platformPath, :productBuildVersion, :productCopyright, :productName, :productVersion
end

def main
  path = nil
  Dir.glob("/Applications/MATLAB_R*.app").each{|matlab_path|
    path = matlab_path if matlab_path =~ /\/Applications\/MATLAB_R(\d+)(\w)\.app/
  }
  result = `xcodebuild -version -sdk 2>/dev/null`

  reg = /(\w+?)\:\s(.*?)\n/

  sdks = []
  result.split("\n\n").each {|sdk_result|
    kv = {}
    sdk_result.scan(reg).each{|r|
      kv[r[0]] = r[1]
    }
    sdks.push SDKInfo.new(
      kv["SDKVersion"],
      kv["Path"],
      kv["PlatformVersion"],
      kv["PlatformPath"],
      kv["ProductBuildVersion"],
      kv["ProductCopyright"],
      kv["ProductName"],
      kv["ProductVersion"]
    ) if kv.keys.size > 0
  }

  return if sdks.size == 0

  sdks.delete_if do |sdk|
     sdk.productName == "iPhone OS"
  end

  return if sdks.size == 0

  sdks.sort! {|a, b| 
    Gem::Version.new(b.SDKVersion) <=> Gem::Version.new(a.SDKVersion)
  }

  mexopts = nil
  File.open("#{path}/bin/mexopts.sh", "r") {|file|
    mexopts = file.read
  }

  mexopts.gsub!(/-sdk macosx\d+.\d+/, "-sdk macosx"+sdks[0].SDKVersion)
  mexopts.gsub!(/-name MacOSX\d+.\d+\.sdk/, "-name MacOSX"+sdks[0].SDKVersion+".sdk")

  begin
    File::open(ARGV[0],"w") {|file|
      file.write(mexopts)
    }
  rescue => e
    puts e
    puts mexopts
  end

end

main