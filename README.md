# iOSClassAddPrefix
##类名加前缀

###第一步：将iOSClassAddPrefix.rb和iOSClassAddPrefixSource.txt拷贝到工程文件同目录下。

###第二步：打开iOSClassAddPrefix.rb文件，修改CLASSPREFIX的值。(CLASSPREFIX即为需要添加的类前缀)

###第三步：在iOSClassAddPrefixSource.txt中添加需要跳过的所有文件和文件夹。如果是文件则该文件不会被遍历，如果是文件夹则该文件夹以及文件夹下的所有文件都不会被遍历。

###第四步：终端cd到同目录下，运行 ruby iOSClassAddPrefix.rb YYModel (YYModel即为工程名)

<br/>
##可能存在的问题:
#####1.文件没有被修改，但是xcode中的文件引用被修改了。
#####2.TableViewController : UITableViewController，运行脚本后会被修改为YYTableViewController : UIYYTableViewController。
#####3.....
###遇到以上的情况需要手动修改。