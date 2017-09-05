CLASSPREFIX = "YY"	#要添加的类前缀

@pwd = Dir.pwd #当前脚本路径
@allClasses = Hash.new #保存所有需要改名的类名
@xcodeprojFile #xcodeprojFile
@sourceFiles

#修改project.pbxproj文件
def changeProjectFile(path)
	filePath = path+@xcodeprojFile+"/project.pbxproj"
	content = File.read filePath
	@allClasses.each do |key, value|
		content = content.gsub(key, value)
	end
	File.write filePath, content
end

#修改类文件中的类引用
def changeClassReference(path)
	Dir.foreach path do |entry|
		if whetherToSkip entry
			next
		end

		#文件的完整路径
		filePath = path+entry
		
		if File.directory? filePath #是文件夹，则递归
			changeClassReference filePath+"/"
		else #是文件，则处理
			content = File.read filePath
			@allClasses.each do |key, value|
				content = content.gsub(key, value)
			end
			File.write filePath, content
		end
	end
end

#修改所有文件名
def changeAllFileName(path)
	Dir.foreach path do |entry|
		if whetherToSkip entry or entry.start_with? CLASSPREFIX #跳过
			next
		end

		#完整的文件路径
		filePath = path+entry

		if File.directory? filePath #是文件夹，则递归
			changeAllFileName filePath+"/"
		end

		tempEntry = entry
		@allClasses.each do |key, value| #修改类名
			tempEntry = tempEntry.gsub(key, value)
		end

		oriFileName = filePath
		newFileName = path+tempEntry

		File::rename oriFileName, newFileName
	end
end

#获取所有需要加前缀的类名
def getAllClassName(path)
	Dir.foreach path do |entry|
		if whetherToSkip entry or entry.start_with? "AppDelegate"
			next
		end

		#文件的完整路径
		filePath = path+entry

		if File.directory? filePath #是文件夹，则递归
			getAllClassName filePath+"/"
		else
			extensionName = entry[/\.[^\.]+$/] #文件的扩展名
			if extensionName == ".h" or extensionName == ".m" or extensionName == ".xib" #只修改.h.m.xib的文件
				fileName = entry.gsub(extensionName, "") #文件名，不包含扩展名
				if File.exist? path+fileName+".h" and File.exist? path+fileName+".m" #.h.m都存在才修改，只有.h则有可能是静态库不能修改
					needChangeFileName = fileName[/[^\+]+$/] #有可能是类别，类别只能修改+后面的部分，因为+前面的部分有可能是系统类
					newFilename = fileName.gsub(needChangeFileName, CLASSPREFIX+needChangeFileName) #修改后的文件名
					saveClassName fileName, newFilename
				end
			end
		end
	end
end

#将需要修改的原文件名和新文件名保存到@allClasses中
def saveClassName(oriFileName, newFileName)
	@allClasses.each do |key, value|
		if key.include? oriFileName
			return
		end
	end

	@allClasses[oriFileName] = newFileName
end

#需要跳过的文件
def whetherToSkip(entry)
	if @sourceFiles and @sourceFiles.count and @sourceFiles == entry
		return true
	end

  	if entry.start_with? "." or entry.start_with? "Pod" or entry.end_with? "framework" or entry.end_with? "xcworkspace" or entry.end_with? ".a" #以./~/Pod开头的文件或文件夹不处理. .. ..DS_Store
    	return true #跳过
  	end

  	if entry.end_with? "xcodeproj" #xcodeproj文件夹不需要遍历
  		if @xcodeprojFile == nil
  			@xcodeprojFile = entry
  		end
  		return true
  	end

  	false
end

#读取sourceFile
def readSourceFile
	path = @pwd+"/iOSClassAddPrefixSource.txt"
	if File.exist? path
		content = File.read(path).lstrip.rstrip
		@sourceFiles = content.split("\n")
	end
end

if ARGV.count == 1 and File.exist? @pwd+"/"+ARGV[0]
	path = @pwd+"/"+ARGV[0]+"/" #工程项目的路径
	readSourceFile
	getAllClassName path
	changeAllFileName path
	changeClassReference path
	changeProjectFile path
else 
	puts "请输入正确的参数"
end