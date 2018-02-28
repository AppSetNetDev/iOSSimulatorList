#! /usr/bin/ruby

require 'fileutils'
require 'csv'
require 'optparse'

DEVPATH = "/Users/xxxxx/Library/Developer/CoreSimulator/Devices"


list = Array.new()

################################################################################
# 
# @brief DEVPATHのディレクトリを列挙する
#
################################################################################
Dir::foreach("#{DEVPATH}") {|f|

      if (/^\./ =~ f)
	     # なにもしない
      else
		path = DEVPATH + "/" + f
		if (File::ftype(path) == "directory")
			list << path
		end
	end
}


################################################################################
# 
# @brief 上で得たディレクトリをループする
#
################################################################################
list.each{|item|
	path = item + "/device.plist"

	if (File.exists?(path) == true)
		devType = nil
		runType = nil

		IO.foreach(path) do |s|
            s.force_encoding('UTF-8')
            s = s.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")

            # デバイスを取得
            s.match(/.*com.apple.CoreSimulator.SimDeviceType.(.*)<\/string>/)
            if ($1.nil? == false)
            	devType = $1
            end

            # OS を取得
            s.match(/.*com.apple.CoreSimulator.SimRuntime.(.*)<\/string>/)
            if ($1.nil? == false)
            	runType = $1
            end

            # リンクを生成
            if (runType != nil && devType != nil) 
            	name = "#{devType}_#{runType}"

                  if File.exists?(name)
                        puts "!! Exist #{name} !!"
                  else
                        puts "Create #{name}"
                  	system("ln -s #{item} #{name}")
                  end
            	break
            end
        end
	end
}
